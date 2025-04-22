import { supabase } from "@/lib/supabaseClient";

const { data } = await supabase
  .from('flows')               // <-- type‑safe!
  .select('id, name')
