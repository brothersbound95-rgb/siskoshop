-- =====================================================================
-- SISKO SHOP — Script à exécuter dans Supabase → SQL Editor
-- (une seule fois, avant d'utiliser les onglets Produits / Statistiques
-- de admin.html et le fichier owner.html)
-- =====================================================================

-- 1) Table des produits (remplace le catalogue codé en dur dans index.html)
create table if not exists products (
    id text primary key,
    name text not null,
    price numeric not null default 0,
    cost numeric not null default 0,        -- coût de revient, visible/éditable UNIQUEMENT dans owner.html
    description text default '',
    colors jsonb not null default '[]',      -- ex: ["Blanc", "Noir"]
    images jsonb not null default '{}',      -- ex: {"Blanc": "https://.../blanc.jpg"}
    popular boolean not null default false,
    active boolean not null default true,
    sort_order integer not null default 0,
    created_at timestamptz not null default now()
);

alter table products enable row level security;

-- Lecture publique (le site vitrine doit pouvoir lire les produits actifs)
create policy if not exists "products_public_read" on products
    for select using (true);

-- Écriture publique via la clé "anon" (comme pour la table orders existante).
-- ⚠️ Simple comme le reste du projet : à durcir plus tard avec de vrais comptes
-- si vous voulez restreindre qui peut modifier le catalogue.
create policy if not exists "products_public_write" on products
    for insert with check (true);
create policy if not exists "products_public_update" on products
    for update using (true);
create policy if not exists "products_public_delete" on products
    for delete using (true);


-- 2) Table des charges diverses (pour le calcul de profit dans owner.html)
create table if not exists expenses (
    id uuid primary key default gen_random_uuid(),
    label text not null,
    amount numeric not null default 0,
    date date not null default current_date,
    created_at timestamptz not null default now()
);

alter table expenses enable row level security;

create policy if not exists "expenses_public_all" on expenses
    for all using (true) with check (true);


-- 3) Bucket de stockage "image" (photos produits)
-- Si le bucket "image" existe déjà (utilisé par index.html), rien à faire.
-- Sinon, créez-le depuis Supabase → Storage → New bucket → nom: "image" → Public : Oui.
