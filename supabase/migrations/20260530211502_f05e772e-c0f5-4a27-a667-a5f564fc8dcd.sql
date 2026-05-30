CREATE TABLE public.external_tracking_sites (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  website_url text NOT NULL,
  api_key text NOT NULL,
  test_endpoint_url text,
  auth_header_name text NOT NULL DEFAULT 'Authorization',
  auth_header_prefix text NOT NULL DEFAULT 'Bearer ',
  description text,
  created_by uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.external_tracking_sites TO authenticated;
GRANT ALL ON public.external_tracking_sites TO service_role;

ALTER TABLE public.external_tracking_sites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins view external sites" ON public.external_tracking_sites
  FOR SELECT TO authenticated USING (public.is_admin(auth.uid()));
CREATE POLICY "Admins insert external sites" ON public.external_tracking_sites
  FOR INSERT TO authenticated WITH CHECK (public.is_admin(auth.uid()));
CREATE POLICY "Admins update external sites" ON public.external_tracking_sites
  FOR UPDATE TO authenticated USING (public.is_admin(auth.uid()));
CREATE POLICY "Admins delete external sites" ON public.external_tracking_sites
  FOR DELETE TO authenticated USING (public.is_admin(auth.uid()));

CREATE TRIGGER update_external_tracking_sites_updated_at
  BEFORE UPDATE ON public.external_tracking_sites
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();