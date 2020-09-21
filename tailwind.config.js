module.exports = {
  purge: ["output/**/*.html"],
  experimental: {
    darkModeVariant: true,
  },
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
  variants: {},
  plugins: [],
};
