module.exports = {
  purge: ["output/**/*.html"],
  darkMode: "media",
  theme: {
    listStyleType: {
      none: "none",
      square: "square",
      decimal: "decimal",
    },
    extend: {
      spacing: {
        a4width: "794px",
      },
      screens: {
        print: { raw: "print" },
      },
      colors: {
        cyan: "#9cdbff",
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
