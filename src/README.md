Format for parsing the recipes:
```ts
type Recipe = {
  tools: string[];
  // NOTE: map[ingredient_name]amount
  inputs: Record<string, string>;
  // NOTE: map[name]amount, first key is the name of the recipe
  outputs: Record<string, string>;
  // NOTE: map[step_number]instruction, can have nested bullet points (may contain syntax errors, like duplicate keys on accident)
  steps: Record<string, string>;
}
```
