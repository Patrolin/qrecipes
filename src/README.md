Format for parsing the recipes:
```ts
type Recipe = {
  /* NOTE: map[reusable_tool_name]void:
    "ceramic mug (≥200ml x2, ≥300ml x1)" = "" */
  tools: Record<string, string>;
  /* NOTE: map[input_name]void:
    "ceramic mug (300ml)" = ""
    "25g coarse-ground fruity coffee beans" = ""
    "100ml milk = "" */
  inputs: Record<string, string>;
  /* NOTE: map[output_name]amount, the first key is the name of the recipe, the ".longetivity" suffix gives shelf life of each product (when present):
    "burger sauce" = "160 ml"
    "burger sauce.longetivity" = "Store for up to 4 weeks in a fridge (same as the mayonnaise)" */
  outputs: Record<string, string>;
  /* NOTE: map[step_number]instruction, can have nested bullet points (may contain syntax errors, like duplicate keys on accident) */
  steps: Record<string, string>;
}
```
