var _G = GameUI.CustomUIConfig();

const DONATE_URL = 'https://smart-lab.ru/uploads/images/00/59/95/2020/02/27/d446dc.jpg';

let _Init = () => {
	_G.ListenJsData('HeroPick', t => {
		if(t.bActive){
			$.GetContextPanel().AddClass('Active');
			$('#HeroPool').RemoveAndDeleteChildren();
			Object.values(t.tHeroes).forEach(tHeroData => AddPickOption(tHeroData));
			SetTimer(t.nEndTime);
		} else {
			$.GetContextPanel().RemoveClass('Active');
		}
	});

	$('#SelectButton').SetPanelEvent('onactivate', ConfirmSelected);

	$('#PassiveTest').SetPanelEvent('onmouseover', ()=> $.DispatchEvent('DOTAShowTextTooltip', $('#PassiveTest'), 'Passive Ability'));
	$('#PassiveTest').SetPanelEvent('onmouseout', ()=> $.DispatchEvent('DOTAHideTextTooltip'));
	$('#ActiveTest').SetPanelEvent('onmouseover', ()=> $.DispatchEvent('DOTAShowTextTooltip', $('#ActiveTest'), 'Active Ability'));
	$('#ActiveTest').SetPanelEvent('onmouseout', ()=> $.DispatchEvent('DOTAHideTextTooltip'));
	$('#TestStyledTooltip').SetPanelEvent('onmouseover', ()=> $.DispatchEvent('DOTAShowTextTooltipStyled', $('#TestStyledTooltip'), 'ПОШЁЛ НАХУЙ ПИДОРАС', 'PerilaTooltip'));
	$('#TestStyledTooltip').SetPanelEvent('onmouseout', ()=> $.DispatchEvent('DOTAHideTextTooltip'));
}

function SetTimer(nEndTime){
	let nRem = nEndTime - Game.GetGameTime();
	if(nRem > 0){
		$('#PickTimer').text = Math.ceil(nRem);
		$.Schedule(0.1, ()=>SetTimer(nEndTime));
	} else {
		$('#PickTimer').text = '';
	}
}

function GetHeroImageName(sHero){
	return `file://{images}/custom_game/hero_pick/${sHero}.png`;
}

/*
	sHero,
	bPaid,
	bLocked,
*/
function AddPickOption(t){
	let hCard = $.CreatePanel('Panel', $('#HeroPool'), '');
	hCard.BLoadLayoutSnippet('HeroPickOption');

	hCard.sHero = t.sHero;

	let hImagePanel = hCard.FindChildTraverse('HeroImage');
	hImagePanel.style.backgroundImage = `url("${GetHeroImageName(t.sHero)}")`;
	hImagePanel.style.backgroundSize = `100% 100%`;

	hCard.SetHasClass('Paid', t.bPaid?true:false);
	hCard.SetHasClass('Locked', t.bLocked?true:false);

	if(t.bLocked){
		hCard.FindChildTraverse('LockedBuyButton').SetPanelEvent('onactivate', () => {
			$.DispatchEvent('ExternalBrowserGoToURL', hCard, DONATE_URL);
		});

		hCard.SetPanelEvent('onmouseover', () => {
			$.DispatchEvent('DOTAShowTextTooltip', hCard, 'ДОП СЛОТ ЗА ДОНАТ');
		});

		hCard.SetPanelEvent('onmouseout', () => {
			$.DispatchEvent('DOTAHideTextTooltip');
		});
	} else {
		hCard.SetPanelEvent('onactivate', () => {
			SelectOption(hCard);
		});
	}
}

function SelectOption(hTarget){
	for(let hCard of $('#HeroPool').Children()){
		if(hCard == hTarget){
			hCard.AddClass('Selected');
			$('#SelectButton').RemoveClass('Inactive');
		} else {
			hCard.RemoveClass('Selected');
		}
	}
}

function GetSelected(){
	for(let hCard of $('#HeroPool').Children()){
		if(hCard.BHasClass('Selected')){
			return hCard;
		}
	}
}

function ConfirmSelected(){
	let hCard = GetSelected();
	if(!hCard) return;

	GameEvents.SendCustomGameEventToServer('sv_select_hero', {
		sHero: hCard.sHero,
	});
}

_Init();