-- Create tables for the invoice app

-- Enable RLS (Row Level Security)
alter table public.profiles enable row level security;

-- Create profiles table
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  updated_at timestamp with time zone,
  username text unique,
  full_name text,
  avatar_url text,
  business_name text,
  business_address text,
  business_gstin text,
  business_pan text,
  business_phone text,
  business_email text,
  constraint username_length check (char_length(username) >= 3)
);

-- Create invoices table
create table public.invoices (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  invoice_number text not null,
  invoice_date timestamp with time zone not null,
  due_date timestamp with time zone not null,
  customer_id uuid,
  customer_name text not null,
  customer_gstin text,
  customer_address text,
  customer_state text,
  customer_state_code text,
  place_of_supply text,
  place_of_supply_code text,
  notes text,
  terms_and_conditions text,
  status smallint not null default 0,
  invoice_type smallint not null default 0,
  is_reverse_charge boolean not null default false,
  is_b2b boolean not null default true,
  is_interstate boolean not null default false,
  subtotal numeric(15,2) not null default 0,
  cgst_total numeric(15,2) not null default 0,
  sgst_total numeric(15,2) not null default 0,
  igst_total numeric(15,2) not null default 0,
  cess_total numeric(15,2) not null default 0,
  total_tax numeric(15,2) not null default 0,
  grand_total numeric(15,2) not null default 0,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Create invoice_items table
create table public.invoice_items (
  id uuid primary key default uuid_generate_v4(),
  invoice_id uuid references public.invoices(id) on delete cascade not null,
  product_id uuid,
  description text not null,
  hsn_sac text,
  quantity numeric(15,3) not null default 1,
  unit text,
  price numeric(15,2) not null default 0,
  discount_percentage numeric(5,2) not null default 0,
  discount_amount numeric(15,2) not null default 0,
  taxable_value numeric(15,2) not null default 0,
  cgst_rate numeric(5,2) not null default 0,
  cgst_amount numeric(15,2) not null default 0,
  sgst_rate numeric(5,2) not null default 0,
  sgst_amount numeric(15,2) not null default 0,
  igst_rate numeric(5,2) not null default 0,
  igst_amount numeric(15,2) not null default 0,
  cess_rate numeric(5,2) not null default 0,
  cess_amount numeric(15,2) not null default 0,
  total numeric(15,2) not null default 0,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Create customers table
create table public.customers (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  name text not null,
  gstin text,
  address text,
  state text,
  state_code text,
  phone text,
  email text,
  contact_person text,
  notes text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Create products table
create table public.products (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  name text not null,
  description text,
  hsn_sac text,
  unit text,
  price numeric(15,2) not null default 0,
  cgst_rate numeric(5,2) not null default 0,
  sgst_rate numeric(5,2) not null default 0,
  igst_rate numeric(5,2) not null default 0,
  cess_rate numeric(5,2) not null default 0,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Create GSTR1 table
create table public.gstr1 (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  gstin text not null,
  return_period text not null,
  data jsonb not null,
  status text not null,
  filing_date timestamp with time zone,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Create GSTR3B table
create table public.gstr3b (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  gstin text not null,
  return_period text not null,
  data jsonb not null,
  status text not null,
  filing_date timestamp with time zone,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Create GSTR4 table
create table public.gstr4 (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  gstin text not null,
  return_period text not null,
  data jsonb not null,
  status text not null,
  filing_date timestamp with time zone,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Create GSTR9 table
create table public.gstr9 (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  gstin text not null,
  financial_year text not null,
  data jsonb not null,
  status text not null,
  filing_date timestamp with time zone,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Create GSTR9C table
create table public.gstr9c (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  gstin text not null,
  financial_year text not null,
  data jsonb not null,
  status text not null,
  filing_date timestamp with time zone,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Create user_settings table
create table public.user_settings (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  key text not null,
  value text not null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  unique(user_id, key)
);

-- Set up RLS policies
-- Profiles table policies
create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );

-- Invoices table policies
create policy "Users can view their own invoices"
  on invoices for select
  using ( auth.uid() = user_id );

create policy "Users can create their own invoices"
  on invoices for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own invoices"
  on invoices for update
  using ( auth.uid() = user_id );

create policy "Users can delete their own invoices"
  on invoices for delete
  using ( auth.uid() = user_id );

-- Invoice items table policies
create policy "Users can view their own invoice items"
  on invoice_items for select
  using ( auth.uid() = (select user_id from invoices where id = invoice_id) );

create policy "Users can create their own invoice items"
  on invoice_items for insert
  with check ( auth.uid() = (select user_id from invoices where id = invoice_id) );

create policy "Users can update their own invoice items"
  on invoice_items for update
  using ( auth.uid() = (select user_id from invoices where id = invoice_id) );

create policy "Users can delete their own invoice items"
  on invoice_items for delete
  using ( auth.uid() = (select user_id from invoices where id = invoice_id) );

-- Similar policies for other tables
-- Customers table policies
create policy "Users can view their own customers"
  on customers for select
  using ( auth.uid() = user_id );

create policy "Users can create their own customers"
  on customers for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own customers"
  on customers for update
  using ( auth.uid() = user_id );

create policy "Users can delete their own customers"
  on customers for delete
  using ( auth.uid() = user_id );

-- Products table policies
create policy "Users can view their own products"
  on products for select
  using ( auth.uid() = user_id );

create policy "Users can create their own products"
  on products for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own products"
  on products for update
  using ( auth.uid() = user_id );

create policy "Users can delete their own products"
  on products for delete
  using ( auth.uid() = user_id );

-- GSTR tables policies
create policy "Users can view their own GSTR1"
  on gstr1 for select
  using ( auth.uid() = user_id );

create policy "Users can create their own GSTR1"
  on gstr1 for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own GSTR1"
  on gstr1 for update
  using ( auth.uid() = user_id );

create policy "Users can delete their own GSTR1"
  on gstr1 for delete
  using ( auth.uid() = user_id );

-- Similar policies for other GSTR tables
-- User settings policies
create policy "Users can view their own settings"
  on user_settings for select
  using ( auth.uid() = user_id );

create policy "Users can create their own settings"
  on user_settings for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own settings"
  on user_settings for update
  using ( auth.uid() = user_id );

create policy "Users can delete their own settings"
  on user_settings for delete
  using ( auth.uid() = user_id );
