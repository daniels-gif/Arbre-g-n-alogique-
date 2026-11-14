-- Extension Espace Enfants : à activer après sauvegarde vérifiée et test.
-- L'espace de découverte est ouvert à la famille, jouer exige une session enfant approuvée.
-- Trois derniers enfants de SOP Wandji Verkys : rangs 4, 5, 6 (génération 3).
create table if not exists public.batcha_kids_sessions(
 token uuid primary key default gen_random_uuid(),
 parent_id uuid not null references public.batcha_people(id),
 child_id uuid not null references public.batcha_people(id),
 expires_at timestamptz not null default (now()+interval '60 minutes'),
 created_at timestamptz not null default now()
);
create index if not exists batcha_kids_sessions_expiry on public.batcha_kids_sessions(expires_at);
alter table public.batcha_kids_sessions enable row level security;
revoke all on public.batcha_kids_sessions from public,anon,authenticated;

create or replace function public.batcha_parent_children(p_parent_id uuid,p_access uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare result jsonb;
begin
 if not exists (
 select 1 from public.batcha_profile_sessions s
 join public.batcha_people p on p.id=s.person_id
 where s.person_id=p_parent_id and s.token=p_access and s.expires_at>now()
 and p.deceased=false and p.code_set=true and p.profile_pin_hash is not null
 ) then raise exception 'Connexion familiale requise pour choisir un enfant.';end if;
 select coalesce(jsonb_agg(jsonb_build_object(
  'id',c.id,'firstname',left(coalesce(nullif(btrim(c.firstname),''),'Enfant'),60))
  order by c.birth_rank nulls last,c.position nulls last,c.created_at),'[]'::jsonb)
 into result
 from public.batcha_people c
 where c.parent_id=p_parent_id and coalesce(c.deceased,false)=false
 and (
  (c.generation=4 and (c.birth_date is null or (c.birth_date<=current_date and c.birth_date>(current_date-interval '18 years')::date)))
  or (p_parent_id='588db644-8fc7-4213-add5-528a53a12eef'::uuid and c.birth_rank in (4,5,6))
 );
 return result;
end $$;
create or replace function public.batcha_kids_session_start(
 p_parent_id uuid,p_access uuid,p_child_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare possible jsonb; item jsonb; new_token uuid;
begin
 possible:=public.batcha_parent_children(p_parent_id,p_access);
 select obj into item from jsonb_array_elements(possible) as obj
 where obj->>'id'=p_child_id::text limit 1;
 if item is null then raise exception 'Profil enfant non autorisé pour cette fiche.';end if;
 insert into public.batcha_kids_sessions(parent_id,child_id) values(p_parent_id,p_child_id)
 returning token into new_token;
 return jsonb_build_object('token',new_token,'expires_in_seconds',3600);
end $$;
create or replace function public.batcha_kids_session_check(p_token uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare child_name text;
begin
 select left(coalesce(nullif(btrim(p.firstname),''),'Enfant'),60) into child_name
 from public.batcha_kids_sessions k
 join public.batcha_people p on p.id=k.child_id
 where k.token=p_token and k.expires_at>now()
 and coalesce(p.deceased,false)=false;
 if child_name is null then return jsonb_build_object('valid',false);end if;
 return jsonb_build_object('valid',true,'name',child_name);
end $$;
create or replace function public.batcha_kids_session_end(p_token uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
begin
 delete from public.batcha_kids_sessions where token=p_token;
 return jsonb_build_object('ok',true);
end $$;
revoke all on function public.batcha_parent_children(uuid,uuid) from public;
revoke all on function public.batcha_kids_session_start(uuid,uuid,uuid) from public;
revoke all on function public.batcha_kids_session_check(uuid) from public;
revoke all on function public.batcha_kids_session_end(uuid) from public;
grant execute on function public.batcha_parent_children(uuid,uuid) to anon,authenticated;
grant execute on function public.batcha_kids_session_start(uuid,uuid,uuid) to anon,authenticated;
grant execute on function public.batcha_kids_session_check(uuid) to anon,authenticated;
grant execute on function public.batcha_kids_session_end(uuid) to anon,authenticated;
