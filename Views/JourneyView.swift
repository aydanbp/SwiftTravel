import SwiftUI
import MapKit

struct JourneyView: View {
    @State var testState: Bool = false
    var destination: String = "Test Destination"
    
    var body: some View {
        

            VStack {
                
                VStack {
                    Spacer()
                    Text("Towards \(destination) Station")
                    Text("\(testState)")
                }
                .frame(maxWidth: .infinity, maxHeight: 80)
                .padding(.vertical)
                .background(.ultraThinMaterial)
                
                
                Spacer()
                    .frame(height: 600) // This creates a fixed-height hole
                    .allowsHitTesting(false) // Allows touches to go through it
                
                VStack{
                    Spacer()
                    HStack {
                        
                        Button("Re-Route Journey", systemImage: "arrow.turn.down.left", action: {
                            testState.toggle()
                        })
                        .foregroundStyle(.white)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                        Spacer()
                        Divider()
                        Spacer()
                        Button("Cancel Journey", systemImage: "xmark", action: {
                            testState.toggle()
                        })
                        .foregroundStyle(.white)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .frame(width: .infinity, height: 100)
                    .padding()
                    .background(.ultraThinMaterial)
                }

            }
            
            .ignoresSafeArea(.all)
            .toolbar(.hidden, for: .tabBar)
        }
    }


#Preview {
    JourneyView()
}
