import "dotenv/config";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "@/generated/prisma/client";

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL is not set");
}

const adapter = new PrismaPg({
  connectionString,
});

const prisma = new PrismaClient({ adapter });

type ScryfallCard = {
  id: string;
  name: string;
  oracle_text?: string;
  mana_cost?: string;
  type_line?: string;
  power?: string;
  toughness?: string;
  colors: string[];
  color_identity: string[];
  keywords: string[];
  cmc: number;
  reserved: boolean;
  digital: boolean;
  image_uris?: {
    normal?: string;
  };
  scryfall_uri: string;
  set: string;
  set_name: string;
  collector_number: string;
  rarity?: string;
  released_at?: string;
};

async function fetchCard(): Promise<ScryfallCard> {
  const response = await fetch(
    "https://api.scryfall.com/cards/named?exact=Lightning%20Bolt",
    {
      headers: {
        Accept: "application/json;q=0.9,*/*;q=0.8",
        "User-Agent": "mtg-ai/0.1.0",
      },
    },
  );

  if (!response.ok) {
    throw new Error(
      `Scryfall request failed: ${response.status} ${response.statusText}`,
    );
  }

  return response.json() as Promise<ScryfallCard>;
}

async function main() {
  const card = await fetchCard();

  await prisma.card.upsert({
    where: {
      id: card.id,
    },
    update: {
      name: card.name,
      oracleText: card.oracle_text ?? null,
      manaCost: card.mana_cost ?? null,
      typeLine: card.type_line ?? null,
      power: card.power ?? null,
      toughness: card.toughness ?? null,
      colors: card.colors,
      colorIdentity: card.color_identity,
      keywords: card.keywords,
      cmc: card.cmc,
      reserved: card.reserved,
      digital: card.digital,
      imageUri: card.image_uris?.normal ?? null,
      scryfallUri: card.scryfall_uri,
    },
    create: {
      id: card.id,
      name: card.name,
      oracleText: card.oracle_text ?? null,
      manaCost: card.mana_cost ?? null,
      typeLine: card.type_line ?? null,
      power: card.power ?? null,
      toughness: card.toughness ?? null,
      colors: card.colors,
      colorIdentity: card.color_identity,
      keywords: card.keywords,
      cmc: card.cmc,
      reserved: card.reserved,
      digital: card.digital,
      imageUri: card.image_uris?.normal ?? null,
      scryfallUri: card.scryfall_uri,
    },
  });

  await prisma.printing.upsert({
    where: {
      setCode_collectorNumber: {
        setCode: card.set,
        collectorNumber: card.collector_number,
      },
    },
    update: {
      cardId: card.id,
      setName: card.set_name,
      rarity: card.rarity ?? null,
      releasedAt: card.released_at
        ? new Date(card.released_at)
        : null,
      imageUri: card.image_uris?.normal ?? null,
      scryfallUri: card.scryfall_uri,
    },
    create: {
      id: `${card.id}-${card.set}-${card.collector_number}`,
      cardId: card.id,
      setCode: card.set,
      setName: card.set_name,
      collectorNumber: card.collector_number,
      rarity: card.rarity ?? null,
      releasedAt: card.released_at
        ? new Date(card.released_at)
        : null,
      imageUri: card.image_uris?.normal ?? null,
      scryfallUri: card.scryfall_uri,
    },
  });

  console.log(`Ingested: ${card.name}`);
  console.log(`Scryfall ID: ${card.id}`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });