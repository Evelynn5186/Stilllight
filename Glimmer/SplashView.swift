import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @State private var ellipse1Opacity: Double = 0.0
    @State private var ellipse2Opacity: Double = 0.0
    @State private var titleOpacity: Double = 0.0
    @State private var characterOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()

            // Baby blue ellipses
            ZStack {
                // Ellipse 1 - top area
                Ellipse()
                    .foregroundColor(.clear)
                    .frame(width: 670, height: 640)
                    .background(Color(red: 0.84, green: 0.91, blue: 1))
                    .clipShape(Ellipse())
                    .blur(radius: 50)
                    .offset(x: -66, y: -269)
                    .opacity(ellipse1Opacity)

                // Ellipse 2 - bottom area
                Ellipse()
                    .foregroundColor(.clear)
                    .frame(width: 757, height: 718)
                    .background(Color(red: 0.84, green: 0.91, blue: 1))
                    .clipShape(Ellipse())
                    .blur(radius: 50)
                    .offset(x: -127, y: 350)
                    .opacity(ellipse2Opacity)
            }

            // Character image
            Image("SplashCharacter")
                .resizable()
                .scaledToFit()
                .frame(width: 367, height: 367)
                .opacity(characterOpacity)
                .offset(x: 17.5, y: -75.5)

            // Title
            Text("Here, today.")
                .font(.custom("Poppins", size: 24))
                .foregroundColor(Color(red: 0.23, green: 0.28, blue: 0.33))
                .opacity(titleOpacity)
                .offset(y: 90)
        }
        .ignoresSafeArea()
        .onAppear {
            // Animate ellipses
            withAnimation(.easeOut(duration: 1.0)) {
                ellipse1Opacity = 1.0
            }

            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                ellipse2Opacity = 1.0
            }

            // Animate character
            withAnimation(.easeIn(duration: 0.8).delay(0.4)) {
                characterOpacity = 1.0
            }

            // Animate title
            withAnimation(.easeIn(duration: 0.6).delay(0.6)) {
                titleOpacity = 1.0
            }

            // Transition to main app
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isActive = false
                }
            }
        }
    }
}

#Preview {
    SplashView(isActive: .constant(true))
}
