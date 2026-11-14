/* Profil joueur : accès réservé à la fiche familiale authentifiée.
   Pas de données de naissance sauvegardées dans le navigateur. */
(function(){
'use strict';
const $=id=>document.getElementById(id);
const endpoint="https://pmourvqtitnytomnduzd.supabase.co/rest/v1/"+'rpc/batcha_kids_game_eligibility';
const key="sb_publishable_N4l5G_krbjL5fjsnUq5QgA_simvsW3V";
const status=$('kidsPlayerStatus'),form=$('kidsPlayerForm'),error=$('kidsPlayerError');
let session=null,needsYear=false;
function credentials(){
 let raw;
 try{raw=JSON.parse(sessionStorage.getItem('sop-family-session-v2')||'null')}catch(_){}
 if(!raw||raw.version!==2||typeof raw.memberId!=='string'||typeof raw.access!=='string')return null;
 const last=Number(raw.lastActivity),elapsed=Date.now()-last;
 if(!Number.isFinite(elapsed)||elapsed<0||elapsed>=30*60*1000)return null;
 return {p_person_id:raw.memberId,p_access:raw.access};
}
async function verify(year){
 const response=await fetch(endpoint,{method:'POST',
 headers:{apikey:key,'Content-Type':'application/json'},
 body:JSON.stringify({...session,p_declared_year:year})
 });
 const data=await response.json();
 if(!response.ok)throw Error(data.message||'Connexion familiale invalide');
 return data;
}
async function initialize(){
 session=credentials();
 if(!session){status.textContent='Connectez-vous à votre fiche familiale pour accéder aux jeux.';return}
 try{
  const info=await verify(null);
  $('kidsPlayerIdentity').textContent='Fiche : '+(info.name||'Membre');
  if(info.needs_birth_parts){status.textContent=info.message;return}
  needsYear=info.needs_year===true;
  $('kidsYearSection').hidden=!needsYear;
  if(!needsYear&&!info.eligible){status.textContent=info.message||'Profil non admissible.';return}
  status.textContent=needsYear?
   'Le jour et le mois figurent déjà dans ta fiche. Indique seulement l’année manquante.':
   'Fiche familiale reconnue. Confirme la participation pour jouer.';
  form.hidden=false;
 }catch(_){status.textContent='Vérification indisponible : la fonction sécurisée doit être activée avant de jouer.'}
}
form.addEventListener('submit',async e=>{
 e.preventDefault();error.textContent='';
 if(!session){error.textContent='Connexion requise.';return}
 const input=$('kidsPlayerYear');
 let year=null;
 if(needsYear){
  year=Number(input.value);
  if(!input.value||!Number.isInteger(year)||year<1900||year>new Date().getFullYear()){
   error.textContent='Indique une année valide.';return;
  }
 }
 try{
  const info=await verify(year);
  if(!info.eligible){error.textContent=info.message||'Le profil ne remplit pas les conditions.';return}
  if(info.age<18&&!$('kidsPlayerApproval').checked){
   error.textContent='L’autorisation d’un parent ou tuteur est nécessaire.';return;
  }
  input.value='';
  window.activateVerifiedKidsPlayer(info);
 }catch(_){error.textContent='Impossible de vérifier la fiche pour le moment.'}
});
initialize();
})();