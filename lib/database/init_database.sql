-- Create tables for the invoice app

-- Invoices table
CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  invoice_number TEXT NOT NULL,
  customer_name TEXT NOT NULL,
  customer_gstin TEXT,
  customer_email TEXT,
  customer_address TEXT,
  invoice_date TIMESTAMP WITH TIME ZONE NOT NULL,
  due_date TIMESTAMP WITH TIME ZONE,
  subtotal DECIMAL(12, 2) NOT NULL,
  tax_total DECIMAL(12, 2) NOT NULL,
  total DECIMAL(12, 2) NOT NULL,
  notes TEXT,
  terms TEXT,
  status SMALLINT NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Invoice items table
CREATE TABLE IF NOT EXISTS invoice_items (
  id UUID PRIMARY KEY,
  invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  quantity DECIMAL(12, 2) NOT NULL,
  unit_price DECIMAL(12, 2) NOT NULL,
  tax_rate DECIMAL(5, 2) NOT NULL,
  tax_amount DECIMAL(12, 2) NOT NULL,
  total_amount DECIMAL(12, 2) NOT NULL,
  hsn_code TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  gstin TEXT,
  email TEXT,
  phone TEXT,
  address TEXT,
  state TEXT,
  state_code TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  hsn_code TEXT,
  unit_price DECIMAL(12, 2) NOT NULL,
  tax_rate DECIMAL(5, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- GSTR1 table
CREATE TABLE IF NOT EXISTS gstr1 (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  gstin TEXT NOT NULL,
  return_period TEXT NOT NULL,
  data JSONB NOT NULL,
  status TEXT NOT NULL,
  filing_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, gstin, return_period)
);

-- GSTR3B table
CREATE TABLE IF NOT EXISTS gstr3b (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  gstin TEXT NOT NULL,
  return_period TEXT NOT NULL,
  data JSONB NOT NULL,
  status TEXT NOT NULL,
  filing_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, gstin, return_period)
);

-- GSTR9 table
CREATE TABLE IF NOT EXISTS gstr9 (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  gstin TEXT NOT NULL,
  financial_year TEXT NOT NULL,
  data JSONB NOT NULL,
  status TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, gstin, financial_year)
);

-- GSTR9C table
CREATE TABLE IF NOT EXISTS gstr9c (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  gstin TEXT NOT NULL,
  financial_year TEXT NOT NULL,
  data JSONB NOT NULL,
  status TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, gstin, financial_year)
);

-- Test writes table (for database testing)
CREATE TABLE IF NOT EXISTS test_writes (
  id TEXT PRIMARY KEY,
  test_value TEXT NOT NULL,
  user_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Health check table (for database connection testing)
CREATE TABLE IF NOT EXISTS health_check (
  id SERIAL PRIMARY KEY,
  status TEXT NOT NULL DEFAULT 'ok',
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert initial health check record
INSERT INTO health_check (status) VALUES ('ok');

-- Create Row Level Security (RLS) policies

-- Enable RLS on all tables
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE gstr1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE gstr3b ENABLE ROW LEVEL SECURITY;
ALTER TABLE gstr9 ENABLE ROW LEVEL SECURITY;
ALTER TABLE gstr9c ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_writes ENABLE ROW LEVEL SECURITY;

-- Create policies for invoices
CREATE POLICY "Users can view their own invoices" 
  ON invoices FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own invoices" 
  ON invoices FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own invoices" 
  ON invoices FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own invoices" 
  ON invoices FOR DELETE 
  USING (auth.uid() = user_id);

-- Create policies for invoice_items
CREATE POLICY "Users can view their own invoice items" 
  ON invoice_items FOR SELECT 
  USING (
    invoice_id IN (
      SELECT id FROM invoices WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own invoice items" 
  ON invoice_items FOR INSERT 
  WITH CHECK (
    invoice_id IN (
      SELECT id FROM invoices WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own invoice items" 
  ON invoice_items FOR UPDATE 
  USING (
    invoice_id IN (
      SELECT id FROM invoices WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own invoice items" 
  ON invoice_items FOR DELETE 
  USING (
    invoice_id IN (
      SELECT id FROM invoices WHERE user_id = auth.uid()
    )
  );

-- Create policies for customers
CREATE POLICY "Users can view their own customers" 
  ON customers FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own customers" 
  ON customers FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own customers" 
  ON customers FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own customers" 
  ON customers FOR DELETE 
  USING (auth.uid() = user_id);

-- Create policies for products
CREATE POLICY "Users can view their own products" 
  ON products FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own products" 
  ON products FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own products" 
  ON products FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own products" 
  ON products FOR DELETE 
  USING (auth.uid() = user_id);

-- Create policies for GSTR1
CREATE POLICY "Users can view their own GSTR1" 
  ON gstr1 FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own GSTR1" 
  ON gstr1 FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own GSTR1" 
  ON gstr1 FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own GSTR1" 
  ON gstr1 FOR DELETE 
  USING (auth.uid() = user_id);

-- Create policies for GSTR3B
CREATE POLICY "Users can view their own GSTR3B" 
  ON gstr3b FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own GSTR3B" 
  ON gstr3b FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own GSTR3B" 
  ON gstr3b FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own GSTR3B" 
  ON gstr3b FOR DELETE 
  USING (auth.uid() = user_id);

-- Create policies for GSTR9
CREATE POLICY "Users can view their own GSTR9" 
  ON gstr9 FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own GSTR9" 
  ON gstr9 FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own GSTR9" 
  ON gstr9 FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own GSTR9" 
  ON gstr9 FOR DELETE 
  USING (auth.uid() = user_id);

-- Create policies for GSTR9C
CREATE POLICY "Users can view their own GSTR9C" 
  ON gstr9c FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own GSTR9C" 
  ON gstr9c FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own GSTR9C" 
  ON gstr9c FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own GSTR9C" 
  ON gstr9c FOR DELETE 
  USING (auth.uid() = user_id);

-- Create policies for test_writes
CREATE POLICY "Users can view their own test writes" 
  ON test_writes FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own test writes" 
  ON test_writes FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own test writes" 
  ON test_writes FOR DELETE 
  USING (auth.uid() = user_id);

-- Create policy for health_check
CREATE POLICY "Anyone can view health check" 
  ON health_check FOR SELECT 
  TO authenticated
  USING (true);
