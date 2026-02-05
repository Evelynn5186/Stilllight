ZStack() {
  Rectangle()
    .foregroundColor(.clear)
    .frame(width: 454, height: 454)
    .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
    .offset(x: 11, y: 20)
  ZStack() {
    Ellipse()
      .foregroundColor(.clear)
      .frame(width: 67, height: 63)
      .offset(x: 0, y: 0)
  }
  .frame(width: 67, height: 63)
  .offset(x: 112.50, y: 122.50)
  VStack(alignment: .leading, spacing: undefined) {
    HStack(spacing: undefined) {
      VStack(spacing: 6) {
        ZStack() {

        }
        .frame(width: 24, height: 24)
        Text("Here")
          .font(Font.custom("Urbanist", size: 12))
          .lineSpacing(16)
          .foregroundColor(.white)
      }
      .padding(EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4))
      VStack(spacing: 6) {
        ZStack() {

        }
        .frame(width: 24, height: 24)
        Text("Journal")
          .font(Font.custom("Urbanist", size: 12))
          .lineSpacing(16)
          .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
      }
      .padding(EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4))
      .frame(height: 66)
      VStack(spacing: 6) {
        ZStack() {

        }
        .frame(width: 24, height: 24)
        Text("Settings")
          .font(Font.custom("Urbanist", size: 12))
          .lineSpacing(16)
          .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
      }
      .padding(EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4))
      .frame(height: 66)
    }
    .cornerRadius(20)
  }
  .frame(width: 375)
  .background(Color(red: 0.18, green: 0.24, blue: 0.29))
  .cornerRadius(30)
  .offset(x: -0.50, y: 386)
  .shadow(
    color: Color(red: 0.17, green: 0.23, blue: 0.28, opacity: 1), radius: 30, y: 20
  )
  VStack(alignment: .leading, spacing: undefined) {
    HStack(spacing: undefined) {
      VStack(spacing: 6) {
        ZStack() {

        }
        .frame(width: 24, height: 24)
        Text("Here")
          .font(Font.custom("Urbanist", size: 12))
          .lineSpacing(16)
          .foregroundColor(.white)
      }
      .padding(EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4))
      VStack(spacing: 6) {
        ZStack() {

        }
        .frame(width: 24, height: 24)
        Text("Journal")
          .font(Font.custom("Urbanist", size: 12))
          .lineSpacing(16)
          .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
      }
      .padding(EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4))
      .frame(height: 66)
      VStack(spacing: 6) {
        ZStack() {

        }
        .frame(width: 24, height: 24)
        Text("Settings")
          .font(Font.custom("Urbanist", size: 12))
          .lineSpacing(16)
          .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
      }
      .padding(EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4))
      .frame(height: 66)
    }
    .cornerRadius(20)
  }
  .frame(width: 375)
  .background(Color(red: 0.24, green: 0.30, blue: 0.34))
  .cornerRadius(30)
  .offset(x: -0.50, y: 386)
  .shadow(
    color: Color(red: 0.17, green: 0.23, blue: 0.28, opacity: 1), radius: 30, y: 20
  )
  ZStack() {
    ZStack() {
      Rectangle()
        .foregroundColor(.clear)
        .frame(width: 375, height: 44)
        .offset(x: -12.50, y: 0)
      Rectangle()
        .foregroundColor(.clear)
        .frame(width: 22, height: 11.33)
        .cornerRadius(2.67)
        .overlay(
          RoundedRectangle(cornerRadius: 2.67)
            .inset(by: 0.50)
            .stroke(.white, lineWidth: 0.50)
        )
        .offset(x: 165.33, y: 3.66)
      Rectangle()
        .foregroundColor(.clear)
        .frame(width: 18, height: 7.33)
        .background(.white)
        .cornerRadius(1.33)
        .offset(x: 165.33, y: 3.66)
      ZStack() {
        Text("9:41")
          .font(Font.custom("PingFang SC", size: 14).weight(.semibold))
          .foregroundColor(.white)
          .offset(x: 0, y: 2.50)
      }
      .frame(width: 54, height: 21)
      .offset(x: -152, y: 1.50)
    }
    .frame(width: 400, height: 44)
    .offset(x: -1, y: 0)
  }
  .frame(width: 402, height: 44)
  .offset(x: 0, y: -415)
  HStack(spacing: 5.41) {
    HStack(spacing: 4.06) {
      Text("Tap the light to mark today.")
        .font(Font.custom("Urbanist", size: 12).weight(.medium))
        .lineSpacing(13.52)
        .foregroundColor(Color(red: 0.66, green: 0.64, blue: 0.62))
    }
  }
  .padding(
    EdgeInsets(top: 4.06, leading: 8.11, bottom: 4.06, trailing: 8.11)
  )
  .frame(width: 187, height: 29)
  .cornerRadius(6759.89)
  .overlay(
    RoundedRectangle(cornerRadius: 6759.89)
      .inset(by: 0.34)
      .stroke(Color(red: 0.66, green: 0.64, blue: 0.62), lineWidth: 0.34)
  )
  .offset(x: 0.50, y: -192.50)
}
.frame(width: 402, height: 874)
.background(Color(red: 0.07, green: 0.09, blue: 0.11))