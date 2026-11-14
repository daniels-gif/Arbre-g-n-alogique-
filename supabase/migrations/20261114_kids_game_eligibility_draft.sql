-- Préparation : ne pas appliquer avant vérification de sauvegarde et tests.
-- Lecture familiale authentifiée pour la seule admissibilité aux jeux.
-- Aucun INSERT / UPDATE dans l'arbre et aucune année déclarée persistée.
create or replace function public.batcha_kids_game_eligibility(
 p_person_id uuid,p_access uuid,p_declared_year integer default null
)
returns jsonb
language plpgsql security definer set search_path=''
as $$
declare
 person public.batcha_people%rowtype;
 d integer; m integer; y integer; birthday date; age integer;
 official_year boolean; display_name text;
begin
 select p.* into person
 from public.batcha_profile_sessions s
 join public.batcha_people p on p.id=s.person_id
 where s.person_id=p_person_id
 and s.token=p_access
 and s.expires_at>now()
 and coalesce(p.deceased,false)=false
 and p.code_set=true and p.profile_pin_hash is not null;
 if not found then raise exception 'Connexion familiale requise.'; end if;
 display_name:=left(trim(concat_ws(' ',nullif(btrim(person.firstname),''),nullif(btrim(person.surname),''))),120);
 d:=coalesce(person.birth_day,extract(day from person.birth_date)::integer);
 m:=coalesce(person.birth_month,extract(month from person.birth_date)::integer);
 y:=coalesce(person.birth_year,extract(year from person.birth_date)::integer);
 official_year:=y is not null;
 if d is null or m is null then
  return jsonb_build_object('eligible',false,'needs_birth_parts',true,
   'name',display_name,'message','Le jour et le mois doivent être confirmés dans la fiche familiale.');
 end if;
 if y is null and p_declared_year is null then
  return jsonb_build_object('eligible',false,'needs_year',true,'name',display_name,
   'birth_day',d,'birth_month',m);
 end if;
 if y is null then y:=p_declared_year;end if;
 if y<1900 or y>extract(year from current_date)::integer then
  return jsonb_build_object('eligible',false,'message','Année de naissance invalide.');end if;
 begin birthday:=make_date(y,m,d);
 exception when others then
  return jsonb_build_object('eligible',false,'message','Date de naissance invalide.');
 end;
 if birthday>current_date then
  return jsonb_build_object('eligible',false,'message','Date de naissance future invalide.');
 end if;
 age:=extract(year from age(current_date,birthday))::integer;
 return jsonb_build_object('eligible',(age between 0 and 18),
 'name',display_name,'age',age,'needs_year',false,'year_confirmed',official_year,
 'message',case when age>18 then 'Jeux réservés aux personnes de 18 ans ou moins.'
 when official_year then 'Âge vérifié à partir de la fiche familiale.'
 else 'Âge calculé à partir de l’année déclarée, à confirmer par un responsable.'end);
end;
$$;
revoke all on function public.batcha_kids_game_eligibility(uuid,uuid,integer) from public;
grant execute on function public.batcha_kids_game_eligibility(uuid,uuid,integer) to anon,authenticated;
