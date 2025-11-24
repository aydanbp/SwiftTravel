import requests
import re
from flask import Flask, request, jsonify
import pymysql.cursors
import config
# Initialization
app = Flask(__name__)

#########################################
######## API KEYS & DB Config ###########
#########################################


TFL_API_KEY = config.TFL_API_KEY
NR_API_KEY_DISRUPTION = config.NR_API_KEY_DISRUPTION
NR_API_KEY_ARRIVAL = config.NR_API_KEY_ARRIVAL

DB_CONFIG = config.DB_CONFIG

# Helper function to safely access nested dictionary/list values
def get_nested_value(source_dict, path_tuple):
    current_value = source_dict
    for key in path_tuple:
        try:
            if isinstance(key, int):
                current_value = current_value[key]
            else:
                current_value = current_value.get(key)
            if current_value is None:
                return None
        except (TypeError, IndexError, KeyError):
            return None
    return current_value

#########################################
######## Arrival Logic ##################
#########################################

def transform_nr_arrival(services_list: list, station_name: str) -> list:
    processed_list = []
    if not isinstance(services_list, list):
        services_list = [services_list] if services_list else []
        
    for service in services_list:
        new_record = {
            "source": "NR",
            "serviceType": "DEPARTURE",
            "stationName": station_name,
            "id": get_nested_value(service, ("serviceID",)),
            "lineName": get_nested_value(service, ("operator",)),
            "platformName": get_nested_value(service, ("platform",)) or "TBC",
            "destinationName": get_nested_value(service, ("destination", 0, "locationName")),
            "timeToStation": None,
            "scheduledTime": get_nested_value(service, ("std",)),
            "estimatedTime": get_nested_value(service, ("etd",)),
            "coachCount": len(get_nested_value(service, ("formation", "coaches")) or [])
        }
        processed_list.append(new_record)
    return processed_list

def transform_tfl_arrivals(arrivals_list: list) -> list:
    processed_list = []
    for arrival in arrivals_list:
        new_record = {
            "source": "TFL",
            "serviceType": "ARRIVAL",
            "stationName": arrival.get("stationName"),
            "id": arrival.get("id"),
            "lineName": arrival.get("lineName"),
            "platformName": arrival.get("platformName", "TBC"),
            "destinationName": arrival.get("destinationName"),
            "timeToStation": arrival.get("timeToStation"),
            "scheduledTime": None,
            "estimatedTime": None,
            "coachCount": None
        }
        processed_list.append(new_record)
    return processed_list

def get_TFLRaw_arrival(naptan_id):
    url = f"https://api.tfl.gov.uk/StopPoint/{naptan_id}/Arrivals"
    try:
        response = requests.get(url)
        response.raise_for_status()
        raw_arrivals = response.json()
        return transform_tfl_arrivals(raw_arrivals)
    except requests.exceptions.RequestException as e:
        print(f"An error occurred in get_TFLRaw_arrival: {e}")
        return []

def get_NRRaw_arrival(crs_code):
    url = f"https://api1.raildata.org.uk/1010-live-departure-board-dep1_2/LDBWS/api/20220120/GetDepartureBoard/{crs_code}"
    headers = {
        'User-Agent': 'MyTransitApp/1.0',
        'x-apikey': NR_API_KEY_ARRIVAL
    }
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        raw_data = response.json()
        station_name = get_nested_value(raw_data, ("locationName",)) or "Unknown Station"
        train_services = get_nested_value(raw_data, ("trainServices",)) or []
        return transform_nr_arrival(train_services, station_name)
    except requests.exceptions.RequestException as e:
        print(f"An error occurred in get_NRRaw_arrival: {e}")
        return []

def get_unified_Arrival(naptan_id, crs_code):
    tfl_data = get_TFLRaw_arrival(naptan_id)
    nr_data = get_NRRaw_arrival(crs_code)
    # Combine lists and return as a single JSON response
    return jsonify(tfl_data + nr_data)

############################################
############# Disruption Logic #############
############################################

def transform_tfl_disruptions(disruptions_list: list) -> list:
    processed_list = []
    if not isinstance(disruptions_list, list):
        disruptions_list = [disruptions_list] if disruptions_list else []
        
    for disruption in disruptions_list:
        new_record = {
            "source": "TFL",
            "statusType": get_nested_value(disruption, ("closureText",)),
            "description": get_nested_value(disruption, ("description",))
        }
        processed_list.append(new_record)
    return processed_list

def transform_nr_disruptions(disruptions_list: list) -> list:
    processed_list = []
    if not isinstance(disruptions_list, list):
        disruptions_list = [disruptions_list] if disruptions_list else []

    for disruption in disruptions_list:
        new_record = {
            "source": "NR",
            "statusType": get_nested_value(disruption, ("tocStatus",)),
            "description": get_nested_value(disruption, ("tocStatusDescription",))
        }
        processed_list.append(new_record)
    return processed_list

def get_TFL_disruption(line_id):
    url = f"https://api.tfl.gov.uk/Line/{line_id}/Disruption"
    try:
        response = requests.get(url)
        response.raise_for_status()
        raw_data = response.json()
        return jsonify(transform_tfl_disruptions(raw_data))
    except requests.exceptions.RequestException as e:
        print(f"TFL Disruption API error: {e}")
        return jsonify({"error": "TFL API request failed", "details": str(e)}), 500

def get_NR_disruption(toc_id):
    url = f"https://api1.raildata.org.uk/1010-disruptions-experience-api-11_0/tocs/{toc_id}/serviceIndicators"
    headers = {
        'User-Agent': 'MyDisruptionApp/1.0',
        'x-apikey': NR_API_KEY_DISRUPTION
    }
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        raw_data = response.json()
        return jsonify(transform_nr_disruptions(raw_data))
    except requests.exceptions.RequestException as e:
        print(f"NR Disruption API error: {e}")
        return jsonify({"error": "National Rail API request failed", "details": str(e)}), 500

#########################################
####### Database Retrieval Logic ########
#########################################

def get_line_data(cursor):
    cursor.execute("SELECT * FROM `lines`")
    raw_lines = cursor.fetchall()
    lines_data = []
    for row in raw_lines:
        lines_data.append({
            "name": row.get('name'),
            "type": row.get('type'),
            "code": row.get('code'),
            "colour": [
                row.get('colour/0'),
                row.get('colour/1'),
                row.get('colour/2')
            ]
        })
    return lines_data

def get_station_data(cursor):
    cursor.execute("SELECT * FROM `stations`")
    raw_stations = cursor.fetchall()
    stations_data = []
    for row in raw_stations:
        stations_data.append({
            "stationName": row.get('stationName'),
            "lat": row.get('lat'),
            "long": row.get('long'),
            "crsCode": row.get('crsCode'),
            "natpanCode": row.get('natpanCode'),
            "FareZone": row.get('FareZone'),
            "Wifi": bool(row.get('Wifi')),
            "serviceType": row.get('serviceType')
        })
    return stations_data


def get_full_station_id(crs_code, natpan_code):
    natpan_part = natpan_code if natpan_code else ""
    return f"{crs_code}|{natpan_part}"

def get_route_data(cursor):
    station_id_lookup = {}
    cursor.execute("SELECT crsCode, natpanCode FROM `stations`")
    
    for row in cursor.fetchall():
        crs_code = row.get('crsCode')
        natpan_code = row.get('natpanCode')
        if crs_code:
            station_id_lookup[crs_code] = get_full_station_id(crs_code, natpan_code)

    print(f"Built a station ID lookup with {len(station_id_lookup)} entries.")

    
    processed_routes = []
    cursor.execute("SELECT * FROM `routes`")

    for route_row in cursor.fetchall():
        from_crs = route_row.get('from')
        to_crs = route_row.get('to')

        
        from_full_id = station_id_lookup.get(from_crs, from_crs)
        to_full_id = station_id_lookup.get(to_crs, to_crs)
        
        route_dict = {
            "from": from_full_id,
            "to": to_full_id,
            "line": route_row.get('line'),
            "weight": route_row.get('weight'),
            "type": route_row.get('type')
        }
        processed_routes.append(route_dict)
        
    return processed_routes



def get_map_data(cursor):
    cursor.execute("SELECT * FROM `mapRoutes`")
    raw_map_routes = cursor.fetchall()
    map_routes_data = []
    for row in raw_map_routes:
        locations = []
        for i in range(37):
            key = f'location/{i}'
            if key in row and row[key]:
                locations.append(row[key])
        
        map_routes_data.append({
            "line": row.get('line'),
            "type": row.get('type'),
            "comment": row.get('comment'),
            "location": locations
            
        })
    return map_routes_data

#########################################
############# API Routes ################
#########################################

@app.route('/DBRetrival')
def get_db_data():
    request_type = request.args.get('request')
    conn = None
    try:
        conn = pymysql.connect(**DB_CONFIG)
        # Use a dictionary cursor to access columns by name
        cursor = conn.cursor(pymysql.cursors.DictCursor)

        if request_type == "lines":
            return jsonify(get_line_data(cursor))
        elif request_type == "stations":
            return jsonify(get_station_data(cursor))
        elif request_type == "mapRoutes":
            return jsonify(get_map_data(cursor))
        elif request_type == "routes":
            return jsonify(get_route_data(cursor))
        else: # Default case if 'request' is missing or different
            combined_data = {
                'lines': get_line_data(cursor),
                'stations': get_station_data(cursor),
                'routes': get_route_data(cursor),
                'mapRoutes': get_map_data(cursor)
            }
            return jsonify(combined_data)

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": "A database error occurred", "details": str(e)}), 500
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return jsonify({"error": "An internal server error occurred", "details": str(e)}), 500
    finally:
        if conn and conn.open:
            conn.close()

@app.route('/unified_api')
def unified_API():
    id_param = request.args.get('id')
    service_type = request.args.get('type')

    if not id_param or not service_type:
        return jsonify({"error": "Missing 'id' or 'type' parameter"}), 400

    ids = id_param.split("|")
    
    if service_type == "T":
        if len(ids) < 2 or not ids[1]:
            return jsonify({"error": "Invalid 'id' format for type 'T'. Expected 'crs|naptan'."}), 400
        return jsonify(get_TFLRaw_arrival(ids[1]))
    
    elif service_type == "N":
        if not ids[0]:
            return jsonify({"error": "Invalid 'id' format for type 'N'. Expected 'crs'."}), 400
        return jsonify(get_NRRaw_arrival(ids[0]))
        
    elif service_type == "C":
        if len(ids) < 2 or not ids[0] or not ids[1]:
            return jsonify({"error": "Invalid 'id' format for type 'C'. Expected 'crs|naptan'."}), 400
        return get_unified_Arrival(ids[1], ids[0])
        
    else:
        return jsonify({"error": f"Invalid type '{service_type}'. Use 'T', 'N', or 'C'."}), 400

@app.route('/disruption_api')
def disrupt_API():
    line_id = request.args.get('id')
    service_type = request.args.get('type')

    if not line_id or not service_type:
        return jsonify({"error": "Missing 'id' or 'type' parameter"}), 400

    if service_type == "T":
        return get_TFL_disruption(line_id)
    elif service_type == "N":
        return get_NR_disruption(line_id)
    else:
        return jsonify({"error": f"Invalid type '{service_type}'. Use 'T' or 'N'."}), 400


if __name__ == '__main__':
    app.run(debug=False, port=5000)
