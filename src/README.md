Format for parsing the recipes:
```ts
/* NOTE: Some recipes have multiple related subrecipes (e.g. cold brew and cold brew coffee),
   these should be displayed together to reduce confusion.
   The name of the whole recipe is the name of the last subrecipe. */
type Recipe = Record<string, Subrecipe>;
type Subrecipe = {
  /* NOTE: If the recipe is copy-pasted from a single source, this is a link to the source,
    otherwise, it's cobbled together from multiple sources + my own experiments */
  source?: string;
  /* NOTE: map[reusable_tool_name_and_amount]url:
    "spoon": null,
    "bartender set": "https://www.youtube.com/watch?v=_UFiGai-8RA", */
  tools: Record<string, string | null>;
  /* NOTE: []input_name_and_amount:
    ["60 ml water", "180 ml whole (4%) milk, or barista oat milk"] */
  inputs: string[];
  /* NOTE: []container_name_and_amount:
    ["2x glass (≥150ml)"] */
  serving: string[];
  /* Shelf life of the product (if present) */
  longetivity?: string;
  /* NOTE: map[step_number]instruction, can have nested bullet points (may contain syntax errors, like duplicate keys on accident) */
  steps: Record<string, string>;
}
```

TODO: make a cooking calculator
- compute ratios ([720, 420] -> 1.5:1)
- convert units
| 1 ml | 1 tsp | 1 tbsp | 1 cup  |
| ~1 g | 4 ml  | 12 ml  | 240 ml |
