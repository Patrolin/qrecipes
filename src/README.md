TODO: generate index.toml with `"path" = "Name"`

Format for parsing the recipes:
```ts
type Recipe = {
  // NOTE: map[tool_name]specification, specification is how many of each type, e.g. `"ceramic mug" = "≥200ml x2, ≥300ml x1"`
  tools: Record<string, string>;
  // NOTE: map[ingredient_name]amount
  inputs: Record<string, string>;
  // NOTE: map[name]amount, first key is the name of the recipe, the ".longetivity" suffix gives shelf life of each product (when present)
  outputs: Record<string, string>;
  // NOTE: map[step_number]instruction, can have nested bullet points (may contain syntax errors, like duplicate keys on accident)
  steps: Record<string, string>;
}
```
