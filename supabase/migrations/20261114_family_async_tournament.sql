-- Tournoi asynchrone SOP Wandji : migration préparatoire.
-- À appliquer au projet Supabase familial avant d'activer le tournoi.
-- Les réponses correctes restent exclusivement en base ; les clients soumettent leurs choix.
create table if not exists public.batcha_tournaments (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 starts_at timestamptz not null default now(),
 ends_at timestamptz not null,
 questions jsonb not null,
 created_at timestamptz not null default now(),
 constraint batcha_tournaments_questions_array check (jsonb_typeof(questions)='array')
);
create table if not exists public.batcha_tournament_entries (
 tournament_id uuid not null references public.batcha_tournaments(id),
 person_id uuid not null references public.batcha_people(id),
 answers jsonb not null,
 score integer not null check(score>=0),
 submitted_at timestamptz not null default now(),
 primary key (tournament_id,person_id)
);
create index if not exists batcha_tournament_entries_ranking
 on public.batcha_tournament_entries(tournament_id,score desc,submitted_at);
alter table public.batcha_tournaments enable row level security;
alter table public.batcha_tournament_entries enable row level security;
revoke all on public.batcha_tournaments,public.batcha_tournament_entries from public,anon,authenticated;
-- Seed unique, déterministe : pas de second tournoi lors des redéploiements.
insert into public.batcha_tournaments(id,title,starts_at,ends_at,questions)
values (
 '739c52dc-f9e1-446b-a7de-49810c03d111',
 '🏆 Grand quiz familial SOP Wandji',
 now(),now()+interval '30 days',
 '[
  {"question":"Comment appelle-t-on la mère de sa mère ?","options":["Tante","Grand-mère","Cousine"],"correct":1},
  {"question":"Une généalogie permet de retrouver…","options":["Les liens de parenté","Les prévisions météo","Les horaires des bus"],"correct":0},
  {"question":"Le frère de ton père est ton…","options":["Neveu","Oncle","Grand-père"],"correct":1},
  {"question":"Comment appelle-t-on les enfants de ses oncles et tantes ?","options":["Cousins","Parents","Petits-enfants"],"correct":0},
  {"question":"Quel est le meilleur moyen de préserver un récit familial ?","options":["Le recueillir avec accord","Le supprimer","Le modifier sans prévenir"],"correct":0},
  {"question":"La sœur de ta mère est ta…","options":["Nièce","Tante","Cousine"],"correct":1},
  {"question":"Le père de ton grand-père est ton…","options":["Arrière-grand-père","Oncle","Cousin"],"correct":0},
  {"question":"Quel principe favorise un projet familial collectif ?","options":["La coopération","Le secret permanent","L’exclusion"],"correct":0},
  {"question":"Les frères et sœurs ont en commun au moins…","options":["Un parent","Une profession","Une ville"],"correct":0},
  {"question":"Une photographie familiale peut servir à…","options":["Préserver un souvenir","Calculer une température","Remplacer un acte officiel"],"correct":0}
 ]'::jsonb
) on conflict(id) do nothing;

create or replace function public.batcha_tournament_status(p_person_id uuid,p_access uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare t public.batcha_tournaments%rowtype; e public.batcha_tournament_entries%rowtype;
q jsonb; entries jsonb; valid_user boolean;
begin
 select exists(select 1 from public.batcha_profile_sessions s
 join public.batcha_people p on p.id=s.person_id
 where s.person_id=p_person_id and s.token=p_access and s.expires_at>now()
 and p.deceased=false and p.code_set=true and p.profile_pin_hash is not null)
 into valid_user;
 if not valid_user then raise exception 'Déverrouillez votre fiche familiale pour participer.';end if;
 select * into t from public.batcha_tournaments order by created_at desc limit 1;
 if t.id is null then return jsonb_build_object('available',false);end if;
 select * into e from public.batcha_tournament_entries
 where tournament_id=t.id and person_id=p_person_id;
 select coalesce(jsonb_agg(jsonb_build_object('question',item->>'question','options',item->'options') order by ord),'[]'::jsonb)
 into q from jsonb_array_elements(t.questions) with ordinality as x(item,ord);
 entries:='[]'::jsonb;
 if now()>=t.ends_at then
 select coalesce(jsonb_agg(jsonb_build_object('name',name,'score',score,'rank',rank) order by rank),'[]'::jsonb)
 into entries from (
 select concat_ws(' ',p.surname,p.firstname) as name, a.score,
 row_number() over(order by a.score desc,a.submitted_at asc,a.person_id) as rank
 from public.batcha_tournament_entries a
 join public.batcha_people p on p.id=a.person_id
 where a.tournament_id=t.id
 ) rankings;
 end if;
 return jsonb_build_object('available',true,'id',t.id,'title',t.title,
 'starts_at',t.starts_at,'ends_at',t.ends_at,
 'open',now()>=t.starts_at and now()<t.ends_at,
 'questions',case when e.person_id is not null then '[]'::jsonb else q end,
 'submitted',e.person_id is not null,
 'my_score',case when now()>=t.ends_at then e.score else null end,
 'participants',(select count(*) from public.batcha_tournament_entries where tournament_id=t.id),
 'leaderboard',entries);
end $$;

create or replace function public.batcha_tournament_submit(p_person_id uuid,p_access uuid,p_tournament_id uuid,p_answers jsonb)
returns jsonb language plpgsql security definer set search_path='' as $$
declare t public.batcha_tournaments%rowtype; item jsonb; answer jsonb;
i integer:=0; total integer:=0; q_count integer;
begin
 if not exists(select 1 from public.batcha_profile_sessions s join public.batcha_people p on p.id=s.person_id
 where s.person_id=p_person_id and s.token=p_access and s.expires_at>now()
 and p.deceased=false and p.code_set=true and p.profile_pin_hash is not null)
 then raise exception 'Connexion familiale requise.';end if;
 select * into t from public.batcha_tournaments where id=p_tournament_id for share;
 if t.id is null or now()<t.starts_at or now()>=t.ends_at
 then raise exception 'Ce tournoi est fermé.';end if;
 if exists(select 1 from public.batcha_tournament_entries where tournament_id=t.id and person_id=p_person_id)
 then raise exception 'Vous avez déjà participé à ce tournoi.';end if;
 q_count:=jsonb_array_length(t.questions);
 if jsonb_typeof(p_answers) is distinct from 'array' or jsonb_array_length(p_answers)<>q_count
 then raise exception 'Répondez à toutes les questions.';end if;
 for item in select value from jsonb_array_elements(t.questions) loop
  answer:=p_answers->i;
  if jsonb_typeof(answer) is distinct from 'number'
   or (answer::text !~ '^[0-9]+$')
   or (answer::text)::integer>=jsonb_array_length(item->'options')
  then raise exception 'Une réponse est invalide.';end if;
  if (answer::text)::integer=(item->>'correct')::integer then total:=total+1;end if;
  i:=i+1;
 end loop;
 insert into public.batcha_tournament_entries(tournament_id,person_id,answers,score)
 values(t.id,p_person_id,p_answers,total);
 return jsonb_build_object('ok',true,'submitted',true,'questions',q_count,
 'message','Participation enregistrée. Le classement sera publié à la clôture.');
end $$;
revoke all on function public.batcha_tournament_status(uuid,uuid) from public;
revoke all on function public.batcha_tournament_submit(uuid,uuid,uuid,jsonb) from public;
grant execute on function public.batcha_tournament_status(uuid,uuid) to anon,authenticated;
grant execute on function public.batcha_tournament_submit(uuid,uuid,uuid,jsonb) to anon,authenticated;
