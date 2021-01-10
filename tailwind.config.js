module.exports = {
  purge: ["output/**/*.html"],
  darkMode: "media",
  theme: {
    listStyleType: {
      none: "none",
      square: "square",
      decimal: "decimal",
    },
    fontFamily: {
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
