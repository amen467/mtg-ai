import { prisma } from "@/lib/db/client";

export async function GET() {
  const result = await prisma.$queryRaw<
    { current_user: string; current_database: string }[]
  >`
    SELECT current_user, current_database();
  `;

  return Response.json(result[0]);
}