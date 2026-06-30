import SwiftUI

struct SplashView: View {
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.white)
                Text("Guts Scoring")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text("Version \(AppConfig.appVersion)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
