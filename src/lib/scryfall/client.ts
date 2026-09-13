const SCRYFALL_API_BASE = "https://api.scryfall.com";

export async function scryfallFetch<T>(path: string): Promise<T> {
    const response = await fetch(`${SCRYFALL_API_BASE}${path}`, {
    headers: {
        Accept: "application/json;q=0.9,*/*;q=0.8",
        "User-Agent": "mtg-ai/0.1.0",
    },
    });

  if (!response.ok) {
    throw new Error(
      `Scryfall API request failed: ${response.status} ${response.statusText}`,
    );
  }

  return response.json() as Promise<T>;
}