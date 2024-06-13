import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

async function main() {
  const support = await prisma.support.upsert({
    where: { id: 1 },
    update: {},
    create: {
      email: "support@saasmvp.org",
      name: "Support"
    },
  });
  //
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
