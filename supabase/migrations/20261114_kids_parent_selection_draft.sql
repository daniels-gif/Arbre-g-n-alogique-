-- Phase 1 Espace Enfants. A NE PAS APPLIQUER AVANT SAUVEGARDE ET VALIDATION.
-- Sélection des enfants directs de moins de 18 ans, uniquement sous session parent vérifiée.
-- Aucun détail de naissance, photo ni donnée privée de l'enfant n'est transmis.
create or replace function public.batcha_parent_children(p_parent_id uuid,p_access uuid)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare result jsonb;
begin
 if not exists (
  select 1 from public.batcha_profile_sessions s
  join public.batcha_people parent on parent.id=s.person_id
  where s.person_id=p_parent_id and s.token=p_access and s.expires_at>now()
    and coalesce(parent.deceased,false)=false
    and parent.code_set=true and parent.profile_pin_hash is not null
 ) then raise exception 'Connexion parentale nécessaire.'; end if;

 select coalesce(jsonb_agg(jsonb_build_object(
  'id',child.id,
  'firstname',left(coalesce(nullif(btrim(child.firstname),''),'Enfant'),60)
 ) order by child.birth_rank nulls last, child.created_at),'[]'::jsonb)
 into result
 from public.batcha_people child
 where child.parent_id=p_parent_id
   and coalesce(child.deceased,false)=false
   and child.birth_date is not null
   and child.birth_date<=current_date
   and child.birth_date>(current_date-interval '18 years')::date;
 return result;
end;
$function$;
revoke all on function public.batcha_parent_children(uuid,uuid) from public;
grant execute on function public.batcha_parent_children(uuid,uuid) to anon,authenticated;