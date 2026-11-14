/* Espace Enfants — jeux locaux. Aucun envoi de données privées. */
(function(){
'use strict';
const el=id=>document.getElementById(id);
let context;
try{context=JSON.parse(sessionStorage.getItem('sop-kids-v1')||'null')}catch(_){}
if(!context||context.version!==1||context.parentVerified!==true||typeof context.name!=='string'||Date.now()-context.issuedAt>=3600000)return;
const shuffle=arr=>{const a=[...arr];for(let i=a.length-1;i>0;i--){const j=Math.floor(Math.random()*(i+1));[a[i],a[j]]=[a[j],a[i]];}return a};
const fruitBank=[
 ['🍍','Ananas',['Ananas','Pastèque','Mangue']],
 ['🥭','Mangue',['Banane','Mangue','Citron']],
 ['🍌','Banane',['Avocat','Papaye','Banane']],
 ['🥑','Avocat',['Avocat','Orange','Noix de coco']],
 ['🐘','Éléphant',['Girafe','Éléphant','Zèbre']],
 ['🦒','Girafe',['Tortue','Lion','Girafe']],
 ['🐢','Tortue',['Tortue','Éléphant','Oiseau']],
 ['🦁','Lion',['Lion','Singe','Girafe']]
];
const logicBank=[
 ['2, 4, 6, …',['8','7','9'],0],
 ['Un carré a combien de côtés ?',['3','4','5'],1],
 ['1, 3, 5, …',['6','8','7'],2],
 ['Quel mot ne correspond pas aux autres ?',['Mangue','Banane','Chaise'],2],
 ['Si aujourd’hui est lundi, demain sera…',['Dimanche','Mardi','Jeudi'],1],
 ['5, 10, 15, …',['20','18','25'],0]
];
function quizController(prefix,questions,drawPrompt){
 let ordered=[],position=0,points=0,answered=false;
 const next=el(prefix+'Next'),answers=el(prefix+'Answers');
 function draw(){
  answered=false;next.hidden=true;answers.replaceChildren();
  const q=ordered[position];
  el(prefix+'Progress').textContent='Question '+(position+1)+' / '+ordered.length+' · ⭐ '+points;
  el(prefix+'Feedback').textContent='';
  drawPrompt(q);
  const choices=shuffle(q.options.map((label,i)=>({label,correct:i===q.correct})));
  choices.forEach(choice=>{
   const button=document.createElement('button');button.type='button';button.textContent=choice.label;
   button.addEventListener('click',()=>{
    if(answered)return;answered=true;
    if(choice.correct)points++;
    for(const b of answers.children){
     b.disabled=true;
     if(b.dataset.correct==='true')b.classList.add('correct');
     else if(b===button)b.classList.add('wrong');
    }
    el(prefix+'Feedback').textContent=choice.correct?'Bravo ! Bonne réponse.':'Une autre réponse était attendue. Continue !';
    next.hidden=false;next.textContent=position===ordered.length-1?'Terminer':'Suivant';
   });
   button.dataset.correct=String(choice.correct);answers.append(button);
  });
 }
 function reset(){
  ordered=shuffle(questions).map(q=>({...q}));position=0;points=0;draw();
 }
 next.addEventListener('click',()=>{
  if(!answered)return;
  position++;
  if(position<ordered.length)draw();
  else{
   answers.replaceChildren();next.hidden=true;
   el(prefix+'Feedback').textContent='🏅 '+points+' bonne(s) réponse(s) sur '+ordered.length+' !';
   el(prefix+'Progress').textContent='Défi terminé !';
   if(prefix==='fruits')el('fruitsPicture').textContent='🎉';
   else el('logicQuestion').textContent='Bravo pour tes efforts !';
   el('kidsProgress').textContent='⭐ Une activité de plus terminée !';
  }
 });
 return {reset};
}
const fruits=quizController('fruits',fruitBank.map(([emoji,name,options])=>({
 emoji,correct:options.indexOf(name),options
})),q=>{el('fruitsPicture').textContent=q.emoji});
const logic=quizController('logic',logicBank.map(([label,options,correct])=>({label,options,correct})),
 q=>{el('logicQuestion').textContent=q.label});
document.querySelector('[data-open="fruits"]')?.addEventListener('click',()=>fruits.reset());
document.querySelector('[data-open="logic"]')?.addEventListener('click',()=>logic.reset());

// Drawing pad: pixels stay on-device; export from local canvas.
const canvas=el('kidsCanvas'),ctx=canvas.getContext('2d');
let ink='#24513c',drawing=false,last=null;
function clear(){
 ctx.fillStyle='#ffffff';ctx.fillRect(0,0,canvas.width,canvas.height);
 ctx.lineWidth=6;ctx.lineCap='round';ctx.lineJoin='round';
}
clear();
el('kidsPalette').addEventListener('click',e=>{
 const b=e.target.closest('[data-color]');if(!b)return;
 ink=b.dataset.color;
 for(const child of el('kidsPalette').children)child.setAttribute('aria-pressed',String(child===b));
});
el('kidsPalette').children[0]?.setAttribute('aria-pressed','true');
function point(e){
 const rect=canvas.getBoundingClientRect();
 return {x:(e.clientX-rect.left)*canvas.width/rect.width,y:(e.clientY-rect.top)*canvas.height/rect.height};
}
canvas.addEventListener('pointerdown',e=>{
 if(el('draw').hidden)return;
 drawing=true;last=point(e);canvas.setPointerCapture(e.pointerId);
 ctx.strokeStyle=ink;ctx.beginPath();ctx.arc(last.x,last.y,3,0,Math.PI*2);ctx.fillStyle=ink;ctx.fill();
});
canvas.addEventListener('pointermove',e=>{
 if(!drawing)return;
 const p=point(e);ctx.beginPath();ctx.strokeStyle=ink;ctx.moveTo(last.x,last.y);ctx.lineTo(p.x,p.y);ctx.stroke();last=p;
});
canvas.addEventListener('pointerup',()=>{drawing=false;last=null});
canvas.addEventListener('pointercancel',()=>{drawing=false;last=null});
el('kidsErase').addEventListener('click',clear);
function download(uri,name){
 const a=document.createElement('a');a.href=uri;a.download=name;document.body.append(a);a.click();a.remove();
}
el('kidsDownload').addEventListener('click',()=>download(canvas.toDataURL('image/png'),'mon-dessin-familial.png'));

// An entirely local birthday card.
const recipient=el('kidsRecipient'),wish=el('kidsWish');
function updateCard(){
 const name=recipient.value.trim();
 el('kidsCardName').textContent=name?'Pour '+name:'Pour une personne spéciale';
 el('kidsCardMessage').textContent=wish.value;
}
recipient.addEventListener('input',updateCard);wish.addEventListener('change',updateCard);updateCard();
el('kidsSaveCard').addEventListener('click',()=>{
 const output=document.createElement('canvas');output.width=900;output.height=570;
 const c=output.getContext('2d');c.fillStyle='#fae8e4';c.fillRect(0,0,900,570);
 c.strokeStyle='#b79757';c.lineWidth=12;c.strokeRect(24,24,852,522);
 c.textAlign='center';c.fillStyle='#754c53';
 c.font='bold 55px Georgia,serif';c.fillText('Joyeux anniversaire !',450,170);
 c.font='bold 38px system-ui,sans-serif';c.fillText(('Pour '+(recipient.value.trim()||'une personne spéciale')).slice(0,55),450,275);
 c.font='27px system-ui,sans-serif';c.fillText(wish.value,450,385);
 c.font='24px system-ui,sans-serif';c.fillText('Avec toute l’affection de la famille',450,470);
 download(output.toDataURL('image/png'),'carte-anniversaire.png');
});
})();
