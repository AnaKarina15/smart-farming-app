const { Client } = require('pg');

async function main() {
  const client = new Client({
    host: 'localhost',
    port: 5433,
    user: 'postgres',
    password: 'postgres',
    database: 'agrofield_db',
  });

  await client.connect();

  // Todos los usuarios
  const users = await client.query(`SELECT id, email, role FROM users ORDER BY email`);
  console.log('\n=== USUARIOS ===');
  console.table(users.rows);

  // Todos los lotes con propietario
  const lotes = await client.query(`
    SELECT 
      u.email,
      l.id,
      l.nombre,
      l."superficieHectareas",
      l."propietarioId"
    FROM lotes l
    JOIN users u ON l."propietarioId" = u.id
    ORDER BY u.email, l."createdAt"
  `);

  console.log('\n=== TODOS LOS LOTES ===');
  console.table(lotes.rows);

  // Suma total por propietario (como lo haría el backend al validar)
  const sumas = await client.query(`
    SELECT 
      "propietarioId",
      u.email,
      COUNT(*) as lotes,
      SUM("superficieHectareas") as total_ha
    FROM lotes l
    JOIN users u ON l."propietarioId" = u.id
    GROUP BY "propietarioId", u.email
  `);
  console.log('\n=== SUMA POR PROPIETARIO ===');
  console.table(sumas.rows);

  await client.end();
}

main().catch(console.error);
