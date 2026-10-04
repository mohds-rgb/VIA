import js from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  { ignores: ["lib/**", "coverage/**"] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
);
