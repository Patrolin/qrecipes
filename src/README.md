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
  /* NOTE: If there is a relevant video of someone making the recipe, this is a link to it. */
  video?: string;
  /* NOTE: map[reusable_tool_name_and_amount]url:
    "spoon": null,
    "bartender set": "https://www.youtube.com/watch?v=_UFiGai-8RA", */
  tools: Record<string, string | null>;
  /* NOTE: []input_name_and_amount:
    ["60 ml water", "180 ml whole (4%) milk, or barista oat milk"] */
  inputs: string[];
  /* NOTE: map[output_name]amount, the first key is the name of the recipe, the ".longetivity" suffix gives shelf life of each product (when present):
    "burger sauce": "160 ml",
    "burger sauce.longetivity": "Store for up to 4 weeks in a fridge (same as the mayonnaise)", */
  outputs: Record<string, string>;
  /* NOTE: map[step_number]instruction, can have nested bullet points (may contain syntax errors, like duplicate keys on accident) */
  steps: Record<string, string>;
}
```
