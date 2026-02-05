ZStack() {
  HStack(spacing: 8) {
    ZStack() {

    }
    .frame(width: 18, height: 18)
    HStack(spacing: 6) {
      Text("Gather a little light")
        .font(Font.custom("Urbanist", size: 14).weight(.medium))
        .lineSpacing(20)
        .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29))
    }
  }
  .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
  .cornerRadius(9999)
  .overlay(
    RoundedRectangle(cornerRadius: 9999)
      .inset(by: 0.50)
      .stroke(Color(red: 0.29, green: 0.29, blue: 0.29), lineWidth: 0.50)
  )
  .offset(x: 0, y: 226)
  VStack(alignment: .leading, spacing: undefined) {
    HStack(spacing: undefined) {
      VStack(spacing: 6) {
        ZStack() {

        }
        .frame(width: 24, height: 24)
        .background(.white)
        Text("Here")
          .font(Font.custom("Urbanist", size: 12))
          .lineSpacing(16)
          .foregroundColor(Color(red: 0.33, green: 0.21, blue: 0.19))
      }
      .padding(EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4))
      VStack(spacing: 6) {
        ZStack() {

        }
        .frame(width: 24, height: 24)
        Text("Journal")
          .font(Font.custom("Urbanist", size: 12))
          .lineSpacing(16)
          .foregroundColor(Color(red: 0.34, green: 0.33, blue: 0.31))
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
          .foregroundColor(Color(red: 0.34, green: 0.33, blue: 0.31))
      }
      .padding(EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4))
      .frame(height: 66)
    }
    .cornerRadius(20)
  }
  .frame(width: 375)
  .background(.white)
  .cornerRadius(30)
  .offset(x: -0.50, y: 386)
  .shadow(
    color: Color(red: 0.98, green: 0.61, blue: 0.27, opacity: 0.20), radius: 30, y: 20
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
            .stroke(.black, lineWidth: 0.50)
        )
        .offset(x: 165.33, y: 3.66)
      Rectangle()
        .foregroundColor(.clear)
        .frame(width: 18, height: 7.33)
        .background(.black)
        .cornerRadius(1.33)
        .offset(x: 165.33, y: 3.66)
      ZStack() {
        Text("9:41")
          .font(Font.custom("PingFang SC", size: 14).weight(.semibold))
          .foregroundColor(.black)
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
}
.frame(width: 402, height: 874)
.background(Color(red: 0.98, green: 0.93, blue: 0.76))