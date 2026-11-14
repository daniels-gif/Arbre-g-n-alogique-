-- Espace Enfants: DRAFT / NE PAS APPLIQUER SANS SAUVEGARDE RESTAURABLE.
-- Tout membre du site peut découvrir l'univers, sans consulter de données d'enfant.
-- La sélection d'un profil enfant enregistré pour jouer nécessite une session familiale
-- valide. Aucun âge n'est inventé quand la date de naissance est incomplète.
-- Éligibles: génération 4 et trois derniers enfants (rangs 4,5,6)
-- de SOP Wandji Verkys (génération 3), confirmés par la famille.
-- Aucune publication ni score partagé n'est enregistré dans cette version.
create table if not exists public.batcha_kids_sessions(
 token uuid primary key default gen_random_uuid(),
 member_id uuid not null references public.batcha_people(id),
 child_id uuid not null references public.batcha_people(id),
 expires_at timestamptz not null default (now()+interval '60 minutes'),
 created_at timestamptz not null default now()
);
create index if not exists batcha_kids_sessions_expiry on public.batcha_kids_sessions(expires_at);
alter table public.batcha_kids_sessions enable row level security;
revoke all on public.batcha_kids_sessions from public,anon,authenticated;

create or replace function public.batcha_kids_profiles(p_member_id uuid,p_access uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare result jsonb;
begin
 if not exists(
  select 1 from public.batcha_profile_sessions s
  join public.batcha_people p on p.id=s.person_id
  where s.person_id=p_member_id and s.token=p_access and s.expires_at>now()
   and p.deceased=false and p.code_set=true and p.profile_pin_hash is not null
 ) then raise exception 'Session familiale vérifiée requise.';end if;
 select coalesce(jsonb_agg(jsonb_build_object(
 'id',c.id,'firstname',left(coalesce(nullif(btrim(c.firstname),''),'Enfant'),60))
 order by c.generation,c.birth_rank nulls last,c.position nulls last,c.created_at),'[]'::jsonb)
 into result
 from public.batcha_people c
 where coalesce(c.deceased,false)=false
 and (
  (c.generation=4 and (c.birth_date is null or
     (c.birth_date<=current_date and c.birth_date>(current_date-interval '18 years')::date)))
  or (c.parent_id='588db644-8fc7-4213-add5-528a53a12eef'::uuid
      and c.generation=3 and c.birth_rank in(4,5,6))
 );
 return result;
end $$;

create or replace function public.batcha_kids_session_start(
 p_member_id uuid,p_access uuid,p_child_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare allowed jsonb; child_data jsonb; issued uuid;
begin
 allowed:=public.batcha_kids_profiles(p_member_id,p_access);
 select value into child_data from jsonb_array_elements(allowed) as x(value)
 where value->>'id'=p_child_id::text limit 1;
 if child_data is null then raise exception 'Ce profil enfant n’est pas disponible.';end if;
 insert into public.batcha_kids_sessions(member_id,child_id)
 values(p_member_id,p_child_id) returning token into issued;
 return jsonb_build_object('token',issued,'expires_in_seconds',3600);
end $$;

create or replace function public.batcha_kids_session_check(p_token uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare name text;
begin
 select left(coalesce(nullif(btrim(p.firstname),''),'Enfant'),60)
 into name
 from public.batcha_kids_sessions s
 join public.batcha_people p on p.id=s.child_id
 where s.token=p_token and s.expires_at>now() and coalesce(p.deceased,false)=false;
 if name is null then return jsonb_build_object('valid',false);end if;
 return jsonb_build_object('valid',true,'name',name);
end $$;

create or replace function public.batcha_kids_session_end(p_token uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
begin
 delete from public.batcha_kids_sessions where token=p_token;
 return jsonb_build_object('ok',true);
end $$;

revoke all on function public.batcha_kids_profiles(uuid,uuid) from public;
revoke all on function public.batcha_kids_session_start(uuid,uuid,uuid) from public;
revoke all on function public.batcha_kids_session_check(uuid) from public;
revoke all on function public.batcha_kids_session_end(uuid) from public;
grant execute on function public.batcha_kids_profiles(uuid,uuid) to anon,authenticated;
grant execute on function public.batcha_kids_session_start(uuid,uuid,uuid) to anon,authenticated;
grant execute on function public.batcha_kids_session_check(uuid) to anon,authenticated;
grant execute on function public.batcha_kids_session_end(uuid) to anon,authenticated;
