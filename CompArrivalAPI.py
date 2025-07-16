import requests, re, json
from flask import Flask, request
app = Flask(__name__)

@app.route('/query_test')
def query_test():
    query = request.args.get('query')
    return '<h1> Input was: {}</h1>'.format(query)

@app.route('/unified_api')
def unified_API():
    id = re.split("\|", request.args.get('id'))
    type = request.args.get('type')
    match type:
        case "T":
            return f"<h1>{get_TFL(id[1])}</h1>"
        case "N":
            return get_NR(id[0])
        case "C":
            return get_unified(id)

    

    
    

    


def get_TFL(natpan):
    TFL_API_KEY = "🤨"
    url = f"https://api.tfl.gov.uk/StopPoint/Search/{natpan}"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        return data
    else:
        return response.status_code
    


def get_NR(crs):
    api_key = "🤨"
    
    url = f"https://api1.raildata.org.uk/1010-live-departure-board-dep1_2/LDBWS/api/20220120/GetDepartureBoard/{crs}"
    
    headers = {
        'User-Agent':'',
        'x-apikey': api_key
    }
    payload = ""

    try:
        response = requests.request("GET", url, data = payload, headers = headers)
        response.raise_for_status() 

        print("Success! Data received.")
        return response.json()

    except requests.exceptions.HTTPError as err:
        print(f"Request Failed. Status Code: {err.response.status_code}")
        return None
    except requests.exceptions.RequestException as err:
        print(f"A network error occurred: {err}")
        return None

def get_unified(id):
    return f"In progress {id}"

# x = "0|123abc"
# txt = re.split("\|", x)
# print(f"Index Zero:\t{txt[0]}")
# data = get_NR("PAD")

# if data:
#     print(json.dumps(data, indent=2))
if __name__ == '__main__':
    app.run(debug=True, port=5000)




