const colors = require("tailwindcss/colors");

module.exports = {
  purge: ["output/**/*.html"],
  darkMode: "media",
  theme: {
    colors: {
      white: colors.white,
      gray: colors.blueGray,
      blue: colors.blue,
      purple: colors.purple,
      red: colors.red,
      green: colors.green,
    },
    listStyleType: {
      none: "none",
      square: "square",
      decimal: "decimal",
    },
    fontFamily: {
      sans: ["PT Sans", "Helvetica", "Arial", "sans-serif"],
      serif: ["PT Serif", "Georgia", "serif"],
    },
    extend: {
      spacing: {
        a4width: "794px",
      },
      screens: {
        print: { raw: "print" },
      },
    },
  },
  variants: {
    extend: {
      padding: ["last"],
    },
  },
  plugins: [],
};
