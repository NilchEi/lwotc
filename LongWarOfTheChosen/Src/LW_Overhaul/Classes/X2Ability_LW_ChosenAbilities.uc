//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_LW_SpecialistAbilitySet.uc
//  AUTHOR:  Grobobobo
//  PURPOSE: Defines all Long War Chosen-specific abilities, Credit to DerBK for some abilities
//---------------------------------------------------------------------------------------

class X2Ability_LW_ChosenAbilities extends X2Ability config(LW_SoldierSkills);

var config int COOLDOWN_AMMO_DUMP;
var config int COOLDOWN_SHIELD_ALLY;
var config int HEAVY_DAZE_TURNS;
var config int COOLDOWN_DETONATE_MINDSHIELD;
var config int STANDARD_DAZE_TURNS;
var config float NONLETHAL_DMGMOD;

var private name ExtractKnowledgeMarkSourceEffectName, ExtractKnowledgeMarkTargetEffectName;

var config array<name> CHOSEN_SUMMON_RNF_DATA;

var const string ChosenSummonContextDesc;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	`Log("LW_ChosenAbilities.CreateTemplates --------------------------------");	
	Templates.AddItem(CreateWarlockReaction());
	Templates.AddItem(CreateAssassinReaction());
	Templates.AddItem(CreateHunterReaction());
	Templates.AddItem(CreateAmmoDump());
	Templates.AddItem(CreateShieldAlly());
	Templates.AddItem(CreateTraitResilience());
	Templates.AddItem(CreateDetonateMindshield());
	Templates.AddItem(CreateYoinkTeleportAbility());
	Templates.AddItem(CreateChosenExtractKnowledgeYoink());
	//Primary weapons like shotgun and rifle daze, secondary like pistols and katana heavy daze while giving a big negative damage modifier
	Templates.AddItem(CreatePrimaryDaze_Passive());
	Templates.AddItem(CreateSecondaryDaze_Passive());
	Templates.AddItem(CreatePrimaryDaze());
	Templates.AddItem(CreateSecondaryDaze());
	Templates.AddItem(CreateFollowerDefeatedEscape());

	return Templates;
}

static function X2AbilityTemplate CreateWarlockReaction()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_RunBehaviorTree ReactionEffect;
	local X2Effect_GrantActionPoints AddAPEffect;
	local array<name> SkipExclusions;
	local X2Condition_UnitProperty UnitPropertyCondition;
	local X2Condition_OnlyOnXCOMTurn TurnCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'WarlockReaction');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_combatstims";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitTakeEffectDamage';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	TurnCondition =new class'X2Condition_OnlyOnXCOMTurn';
	Template.AbilityShooterConditions.AddItem(TurnCondition);
	
	// The unit must be alive and not stunned
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeAlive = false;
	UnitPropertyCondition.ExcludeStunned = true;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	AddAPEffect = new class'X2Effect_GrantActionPoints';
	AddAPEffect.NumActionPoints = 1;
	AddAPEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	Template.AddTargetEffect(AddAPEffect);

	ReactionEffect = new class'X2Effect_RunBehaviorTree';
	ReactionEffect.BehaviorTreeName = 'WarlockReaction';
	Template.AddTargetEffect(ReactionEffect);

	Template.bShowActivation = true;
	Template.bSkipExitCoverWhenFiring = true;
	Template.bSkipFireAction = true;

	Template.FrameAbilityCameraType = eCameraFraming_Always;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate CreateAssassinReaction()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_RunBehaviorTree ReactionEffect;
	local X2Effect_GrantActionPoints AddAPEffect;
	local array<name> SkipExclusions;
	local X2Condition_UnitProperty UnitPropertyCondition;
	local X2Condition_OnlyOnXCOMTurn TurnCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'AssassinReaction');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_combatstims";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	TurnCondition =new class'X2Condition_OnlyOnXCOMTurn';
	Template.AbilityShooterConditions.AddItem(TurnCondition);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitTakeEffectDamage';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	// The unit must be alive and not stunned
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeAlive = false;
	UnitPropertyCondition.ExcludeStunned = true;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	AddAPEffect = new class'X2Effect_GrantActionPoints';
	AddAPEffect.NumActionPoints = 1;
	AddAPEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	Template.AddTargetEffect(AddAPEffect);

	ReactionEffect = new class'X2Effect_RunBehaviorTree';
	ReactionEffect.BehaviorTreeName = 'AssassinReaction';
	Template.AddTargetEffect(ReactionEffect);

	Template.bShowActivation = true;
	Template.bSkipExitCoverWhenFiring = true;
	Template.bSkipFireAction = true;

	Template.FrameAbilityCameraType = eCameraFraming_Always;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate CreateHunterReaction()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_RunBehaviorTree ReactionEffect;
	local X2Effect_GrantActionPoints AddAPEffect;
	local array<name> SkipExclusions;
	local X2Condition_UnitProperty UnitPropertyCondition;
	local X2Condition_OnlyOnXCOMTurn TurnCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'HunterReaction');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_combatstims";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	TurnCondition =new class'X2Condition_OnlyOnXCOMTurn';
	Template.AbilityShooterConditions.AddItem(TurnCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitTakeEffectDamage';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	// The unit must be alive and not stunned
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeAlive = false;
	UnitPropertyCondition.ExcludeStunned = true;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	AddAPEffect = new class'X2Effect_GrantActionPoints';
	AddAPEffect.NumActionPoints = 1;
	AddAPEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	Template.AddTargetEffect(AddAPEffect);

	ReactionEffect = new class'X2Effect_RunBehaviorTree';
	ReactionEffect.BehaviorTreeName = 'HunterReaction';
	Template.AddTargetEffect(ReactionEffect);

	Template.bShowActivation = true;
	Template.bSkipExitCoverWhenFiring = true;
	Template.bSkipFireAction = true;

	Template.FrameAbilityCameraType = eCameraFraming_Always;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate CreateAmmoDump()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown_LocalAndGlobal Cooldown;
	local X2Condition_UnitProperty TargetCondition;
	local array<name> SkipExclusions;
	local X2Effect_DisableWeapon DisableWeapon;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'AmmoDump_LW');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_mindscorch";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = default.COOLDOWN_AMMO_DUMP;
	Cooldown.NumGlobalTurns = default.COOLDOWN_AMMO_DUMP;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.Deadeye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeAlive = false;
	TargetCondition.ExcludeDead = true;
	TargetCondition.ExcludeFriendlyToSource = true;
	TargetCondition.ExcludeHostileToSource = false;
	TargetCondition.ExcludeCivilian = true;
	TargetCondition.ExcludeCosmetic = true;
	TargetCondition.ExcludeRobotic = false;
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	DisableWeapon = new class'X2Effect_DisableWeapon';
	Template.AddTargetEffect(DisableWeapon);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
		
	Template.ActionFireClass = class'XComGame.X2Action_Fire_MindScorch';
	Template.bShowActivation = true;
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.CustomFireAnim = 'HL_MindScorch';
	Template.CinescriptCameraType = "Warlock_SpectralZombie";
	//Template.CinescriptCameraType = "ChosenWarlock_MindScorch";

	return Template;
}

static function X2AbilityTemplate CreateShieldAlly()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown_LocalAndGlobal Cooldown;
	local X2Condition_UnitProperty TargetCondition;
	local array<name> SkipExclusions;
	local X2Effect_PersistentStatChange ShieldedEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShieldAlly_LW');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_mindscorch";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = default.COOLDOWN_SHIELD_ALLY;
	Cooldown.NumGlobalTurns = default.COOLDOWN_SHIELD_ALLY;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.Deadeye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeAlive = false;
	TargetCondition.ExcludeDead = true;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.ExcludeHostileToSource = true;
	TargetCondition.ExcludeCivilian = true;
	TargetCondition.ExcludeCosmetic = true;
	TargetCondition.ExcludeRobotic = true;
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	ShieldedEffect = CreateShieldedEffect(Template.LocFriendlyName, Template.GetMyLongDescription(), 3);
	Template.AddTargetEffect(ShieldedEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
		
	Template.ActionFireClass = class'XComGame.X2Action_Fire_MindScorch';
	Template.bShowActivation = true;
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.CustomFireAnim = 'HL_MindScorch';
	Template.CinescriptCameraType = "Warlock_SpectralZombie";
	//Template.CinescriptCameraType = "ChosenWarlock_MindScorch";

	return Template;
}

static function X2Effect_PersistentStatChange CreateShieldedEffect(string FriendlyName, string LongDescription, int ShieldHPAmount)
{
	local X2Effect_EnergyShield ShieldedEffect;

	ShieldedEffect = new class'X2Effect_EnergyShield';
	ShieldedEffect.BuildPersistentEffect(10, false, true, , eGameRule_PlayerTurnEnd);
	ShieldedEffect.SetDisplayInfo(ePerkBuff_Bonus, FriendlyName, LongDescription, "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);
	ShieldedEffect.AddPersistentStatChange(eStat_ShieldHP, ShieldHPAmount);
	ShieldedEffect.EffectRemovedVisualizationFn = OnShieldRemoved_BuildVisualization;

	return ShieldedEffect;
}

simulated function OnShieldRemoved_BuildVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;

	if (XGUnit(ActionMetadata.VisualizeActor).IsAlive())
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, class'XLocalizedData'.default.ShieldRemovedMsg, '', eColor_Bad, , 0.75, true);
	}
}

static function X2AbilityTemplate CreateDetonateMindshield()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown_LocalAndGlobal Cooldown;
	local X2Effect_HeavyDazed DazedEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DetonateMindshield_LW');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_fuse";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.Hostility = eHostility_Offensive;
	Template.bLimitTargetIcons = true;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = default.COOLDOWN_DETONATE_MINDSHIELD;
	Cooldown.NumGlobalTurns = default.COOLDOWN_DETONATE_MINDSHIELD;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);	
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_DetonateMindshieldTarget');	
	Template.AddShooterEffectExclusions();

	DazedEffect = class'X2StatusEffects_LW'.static.CreateHeavyDazedStatusEffect(default.HEAVY_DAZE_TURNS, 500);
	DazedEffect.bRemoveWhenSourceDies = true;

	DazedEffect = class'X2StatusEffects_LW'.static.CreateHeavyDazedStatusEffect(default.HEAVY_DAZE_TURNS, 500);
	DazedEffect.bRemoveWhenSourceDies = true;
	Template.AddTargetEffect(DazedEffect);

	//Template.PostActivationEvents.AddItem(default.DetonateMindshieldEventName);
	//Template.PostActivationEvents.AddItem(default.DetonateMindshieldPostEventName);


//	BrutalEffect = new class'X2Effect_Brutal';
//	BrutalEffect.WillMod = -10;
//	Template.AddTargetEffect(BrutalEffect);
// ABC makes all chosen abilities decrease will, not sure if I want that yet

	Template.bShowActivation = true;
	Template.CustomFireAnim = 'HL_MindScorch';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.TargetingMethod = class'X2TargetingMethod_DetonateMindshield';
	Template.CinescriptCameraType = "Psionic_FireAtUnit";

	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	return Template;
}

static function X2AbilityTemplate CreatePrimaryDaze_Passive()
{
	local X2AbilityTemplate Template;
	local X2Effect_PrimaryDaze Effect;
	local X2Effect_GeneralDamageModifier DamageEffect;

	Template = PurePassive('Primary_Daze_Passive', "img:///UILibrary_LW_PerkPack.LW_AbilityCenterMass", false);

	Effect = new class'X2Effect_PrimaryDaze';
	Effect.BuildPersistentEffect(1, true);
	Template.AddTargetEffect(Effect);

	DamageEffect = new class'X2Effect_GeneralDamageModifier';
	DamageEffect.DamageModifier = default.NONLETHAL_DMGMOD;
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddShooterEffect(DamageEffect);

	Template.AdditionalAbilities.AddItem('Primary_Daze');

	return Template;
}

static function X2DataTemplate CreatePrimaryDaze()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Dazed DazedEffect;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'Primary_Daze');

	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilityCenterMass";
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	//	Singe is triggered by an Event Listener registered in X2Effect_Singe
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	DazedEffect = class'X2StatusEffects_XPack'.static.CreateDazedStatusEffect(default.STANDARD_DAZE_TURNS, 500);
	DazedEffect.bRemoveWhenSourceDies = true;

	DazedEffect = class'X2StatusEffects_XPack'.static.CreateDazedStatusEffect(default.STANDARD_DAZE_TURNS, 500);
	DazedEffect.bRemoveWhenSourceDies = true;
	Template.AddTargetEffect(DazedEffect);

	Template.FrameAbilityCameraType = eCameraFraming_Never; 
	Template.bSkipExitCoverWhenFiring = true;
	Template.bSkipFireAction = true;	//	this fire action will be merged by Merge Vis function
	Template.bShowActivation = true;
	Template.bUsesFiringCamera = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.MergeVisualizationFn = Daze_MergeVisualization;
	Template.BuildInterruptGameStateFn = none;

	return Template;
}

static function X2AbilityTemplate CreateSecondaryDaze_Passive()
{
	local X2AbilityTemplate Template;
	local X2Effect_SecondaryDaze Effect;
	local X2Effect_GeneralDamageModifier DamageEffect;

	Template = PurePassive('Secondary_Daze_Passive', "img:///UILibrary_LW_PerkPack.LW_AbilityCenterMass", false);

	Effect = new class'X2Effect_SecondaryDaze';
	Effect.BuildPersistentEffect(1, true);
	Template.AddTargetEffect(Effect);

	DamageEffect = new class'X2Effect_GeneralDamageModifier';
	DamageEffect.DamageModifier = default.NONLETHAL_DMGMOD;
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddShooterEffect(DamageEffect);

	Template.AdditionalAbilities.AddItem('Secondary_Daze');

	return Template;
}

static function X2DataTemplate CreateSecondaryDaze()
{
	local X2AbilityTemplate Template;
	local X2Effect_HeavyDazed DazedEffect;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'Secondary_Daze');

	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilityCenterMass";
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	//	Singe is triggered by an Event Listener registered in X2Effect_Singe
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	DazedEffect = class'X2StatusEffects_LW'.static.CreateHeavyDazedStatusEffect(default.STANDARD_DAZE_TURNS, 100);
	DazedEffect.bRemoveWhenSourceDies = true;
	Template.AddTargetEffect(DazedEffect);

	Template.FrameAbilityCameraType = eCameraFraming_Never; 
	Template.bSkipExitCoverWhenFiring = true;
	Template.bSkipFireAction = true;	//	this fire action will be merged by Merge Vis function
	Template.bShowActivation = true;
	Template.bUsesFiringCamera = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.MergeVisualizationFn = Daze_MergeVisualization;
	Template.BuildInterruptGameStateFn = none;

	return Template;

}

//Taken from Iridar's Singe ability
static function Daze_MergeVisualization(X2Action BuildTree, out X2Action VisualizationTree)
{
	local XComGameStateVisualizationMgr		VisMgr;
	local array<X2Action>					arrActions;
	local X2Action_MarkerTreeInsertBegin	MarkerStart;
	local X2Action_MarkerTreeInsertEnd		MarkerEnd;
	local X2Action							WaitAction;
	local X2Action_MarkerNamed				MarkerAction;
	local XComGameStateContext_Ability		AbilityContext;
	local VisualizationActionMetadata		ActionMetadata;
	local bool bFoundHistoryIndex;
	local int i;

	VisMgr = `XCOMVISUALIZATIONMGR;
	
	MarkerStart = X2Action_MarkerTreeInsertBegin(VisMgr.GetNodeOfType(BuildTree, class'X2Action_MarkerTreeInsertBegin'));
	AbilityContext = XComGameStateContext_Ability(MarkerStart.StateChangeContext);

	//	Find all Fire Actions in the Triggering Shot's Vis Tree
	VisMgr.GetNodesOfType(VisualizationTree, class'X2Action_Fire', arrActions);

	//	Cycle through all of them to find the Fire Action we need, which will have the same History Index as specified in Singe's Context, which gets set in the Event Listener
	for (i = 0; i < arrActions.Length; i++)
	{
		if (arrActions[i].StateChangeContext.AssociatedState.HistoryIndex == AbilityContext.DesiredVisualizationBlockIndex)
		{
			bFoundHistoryIndex = true;
			break;
		}
	}
	//	If we didn't find the correct action, we call the failsafe Merge Vis Function, which will make both Singe's Target Effects apply seperately after the ability finishes.
	//	Looks bad, but at least nothing is broken.
	if (!bFoundHistoryIndex)
	{
		AbilityContext.SuperMergeIntoVisualizationTree(BuildTree, VisualizationTree);
		return;
	}

	//	Add a Wait For Effect Action after the Triggering Shot's Fire Action. This will allow Singe's Effects to visualize the moment the Triggering Shot connects with the target.
	AbilityContext = XComGameStateContext_Ability(arrActions[i].StateChangeContext);
	ActionMetaData = arrActions[i].Metadata;
	WaitAction = class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetaData, AbilityContext,, arrActions[i]);

	//	Insert the Singe's Vis Tree right after the Wait For Effect Action
	VisMgr.ConnectAction(MarkerStart, VisualizationTree,, WaitAction);

	//	Main part of Merge Vis is done, now we just tidy up the ending part. As I understood from MrNice, this is necessary to make sure Vis will look fine if Fire Action ends before Singe finishes visualizing
	//	which tbh sounds like a super edge case, but okay
	//	Find all marker actions in the Triggering Shot Vis Tree.
	VisMgr.GetNodesOfType(VisualizationTree, class'X2Action_MarkerNamed', arrActions);

	//	Cycle through them and find the 'Join' Marker that comes after the Triggering Shot's Fire Action.
	for (i = 0; i < arrActions.Length; i++)
	{
		MarkerAction = X2Action_MarkerNamed(arrActions[i]);

		if (MarkerAction.MarkerName == 'Join' && MarkerAction.StateChangeContext.AssociatedState.HistoryIndex == AbilityContext.DesiredVisualizationBlockIndex)
		{
			//	Grab the last Action in the Singe Vis Tree
			MarkerEnd = X2Action_MarkerTreeInsertEnd(VisMgr.GetNodeOfType(BuildTree, class'X2Action_MarkerTreeInsertEnd'));

			//	TBH can't imagine circumstances where MarkerEnd wouldn't exist, but okay
			if (MarkerEnd != none)
			{
				//	"tie the shoelaces". Vis Tree won't move forward until both Singe Vis Tree and Triggering Shot's Fire action are not fully visualized.
				VisMgr.ConnectAction(MarkerEnd, VisualizationTree,,, MarkerAction.ParentActions);
				VisMgr.ConnectAction(MarkerAction, BuildTree,, MarkerEnd);
			}
			else
			{
				//	not sure what this does
				VisMgr.GetAllLeafNodes(BuildTree, arrActions);
				VisMgr.ConnectAction(MarkerAction, BuildTree,,, arrActions);
			}

			//VisMgr.ConnectAction(MarkerAction, VisualizationTree,, MarkerEnd);
			break;
		}
	}
}

static function X2DataTemplate CreateYoinkTeleportAbility()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2Condition_UnblockedNeighborTile UnblockedNeighborTileCondition;
	local X2Effect_TeleportGetOverThere		GetOverThereEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Yoink');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Vengeance";
	Template.CustomFireAnim = 'HL_ExchangeStart';
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	// There must be a free tile around the source unit
	UnblockedNeighborTileCondition = new class'X2Condition_UnblockedNeighborTile';
	Template.AbilityTargetConditions.AddItem(UnblockedNeighborTileCondition);

	SetChosenKidnapExtractBaseConditions(Template);

	Template.AbilityTargetConditions.AddItem(new class'X2Condition_Wrath');

	Template.AbilityTargetStyle = new class'X2AbilityTarget_Single';
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityToHitCalc = default.DeadEye;

	GetOverThereEffect = new class'X2Effect_TeleportGetOverThere';
	Template.AddTargetEffect(GetOverThereEffect);

	Template.AdditionalAbilities.AddItem('ChosenExtractKnowledgeYoink');

	Template.Hostility = eHostility_Offensive;
	Template.bSkipFireAction = true;
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.CinescriptCameraType = "Cyberus_Teleport";
//BEGIN AUTOGENERATED CODE: Template Overrides 'SkirmisherVengeance'
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
//END AUTOGENERATED CODE: Template Overrides 'SkirmisherVengeance'

	return Template;
}

static function X2DataTemplate CreateChosenExtractKnowledgeYoink()
{
	local X2AbilityTemplate Template;
	local X2Effect_Persistent MarkForExtractKnowledgeEffect;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityTrigger_EventListener AbilityTrigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ChosenExtractKnowledgeYoink');

	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_extractknowledge";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	AbilityTrigger = new class'X2AbilityTrigger_EventListener';
	AbilityTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	AbilityTrigger.ListenerData.EventID = 'Teleportextractknowledge';
	AbilityTrigger.ListenerData.Filter = eFilter_Unit;
	AbilityTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_OriginalTarget;
	Template.AbilityTriggers.AddItem(AbilityTrigger);

	Template.AdditionalAbilities.AddItem('ChosenExtractKnowledge');

	MarkForExtractKnowledgeEffect = new class'X2Effect_Persistent';
	MarkForExtractKnowledgeEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	MarkForExtractKnowledgeEffect.DuplicateResponse = eDupe_Allow;
	MarkForExtractKnowledgeEffect.EffectName = default.ExtractKnowledgeMarkSourceEffectName;
	Template.AddShooterEffect(MarkForExtractKnowledgeEffect);

	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	SetChosenKidnapExtractBaseConditions(Template);

	MarkForExtractKnowledgeEffect = new class'X2Effect_Persistent';
	MarkForExtractKnowledgeEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	MarkForExtractKnowledgeEffect.DuplicateResponse = eDupe_Allow;
	MarkForExtractKnowledgeEffect.EffectName = default.ExtractKnowledgeMarkTargetEffectName;
	Template.AddTargetEffect(MarkForExtractKnowledgeEffect);

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildVisualizationFn = ChosenMoveToEscape_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;

	Template.bSkipFireAction = true;
	Template.bShowActivation = false;

//BEGIN AUTOGENERATED CODE: Template Overrides 'ChosenExtractKnowledgeMove'
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.CinescriptCameraType = "";
//END AUTOGENERATED CODE: Template Overrides 'ChosenExtractKnowledgeMove'

	Template.PostActivationEvents.AddItem('ChosenExtractKnowledgeTrigger');

	return Template;
}

simulated function ChosenMoveToEscape_BuildVisualization(XComGameState VisualizeGameState)
{
	// Trigger the Chosen's kidnap or extract preparation line
	class'XComGameState_NarrativeManager'.static.BuildVisualizationForDynamicNarrative(VisualizeGameState, false, 'ChosenMoveToEscape');
	TypicalAbility_BuildVisualization(VisualizeGameState);
}

static function SetChosenKidnapExtractBaseConditions(out X2AbilityTemplate Template, int iRange=-1)
{
	local X2Condition_UnitProperty UnitPropertyCondition;
	local X2Condition_UnitType ExcludeVolunteerArmyCondition;
	local X2Condition_UnitEffects ExcludeEffects;
	local X2Condition_TargetHasOneOfTheEffects NeedOneOfTheEffects;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// The Target must be alive and a humanoid
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeRobotic = true;
	UnitPropertyCondition.ExcludeAlien = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	UnitPropertyCondition.RequireUnitSelectedFromHQ = true;
	UnitPropertyCondition.ExcludeAdvent = true;
	if (iRange > 0)
	{
		UnitPropertyCondition.RequireWithinRange = true;
		UnitPropertyCondition.WithinRange = iRange;
	}
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	ExcludeVolunteerArmyCondition = new class'X2Condition_UnitType';
	ExcludeVolunteerArmyCondition.ExcludeTypes.AddItem('CivilianMilitia');
	Template.AbilityTargetConditions.AddItem(ExcludeVolunteerArmyCondition);

	// Cannot target units being carried.
	ExcludeEffects = new class'X2Condition_UnitEffects';
	ExcludeEffects.AddExcludeEffect(class'X2Ability_CarryUnit'.default.CarryUnitEffectName, 'AA_UnitIsImmune');
	ExcludeEffects.AddExcludeEffect(class'X2AbilityTemplateManager'.default.BeingCarriedEffectName, 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(ExcludeEffects);

	NeedOneOfTheEffects=new class'X2Condition_TargetHasOneOfTheEffects';
	NeedOneOfTheEffects.EffectNames.AddItem(class'X2AbilityTemplateManager'.default.DazedName);
	NeedOneOfTheEffects.EffectNames.AddItem(class'X2StatusEffects_LW'.default.HeavyDazedName);
	Template.AbilityTargetConditions.AddItem(NeedOneOfTheEffects);
}

static function X2AbilityTemplate CreateTraitResilience()
{
	local X2AbilityTemplate					Template;
	local X2Effect_Resilience				MyCritModifier;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ChosenCritImmune');

	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilityResilience";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;

	MyCritModifier = new class 'X2Effect_Resilience';
	MyCritModifier.CritDef_Bonus = 200;
	MyCritModifier.BuildPersistentEffect (1, true, false, true);
	MyCritModifier.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (MyCritModifier);

	Template.bCrossClassEligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;		
}

static function X2AbilityTemplate CreateFollowerDefeatedEscape()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener EventTrigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'FollowerDefeatedEscape');

	Template.bDontDisplayInAbilitySummary = true;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = 'UnitDied';
	EventTrigger.ListenerData.Filter = eFilter_Unit;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(EventTrigger);

	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;
	Template.BuildNewGameStateFn = FollowerDefeatedEscape_BuildGameState;
	Template.BuildVisualizationFn = FollowerDefeatedEscape_BuildVisualization;
	Template.AssociatedPlayTiming = SPT_AfterParallel;  // play after the follower death that initiated this ability

	return Template;
}

static function XComGameState FollowerDefeatedEscape_BuildGameState(XComGameStateContext Context)
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local X2EventManager EventManager;

	EventManager = `XEVENTMGR;
	History = `XCOMHISTORY;

	NewGameState = History.CreateNewGameState(true, Context);

	TypicalAbility_FillOutGameState(NewGameState);

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComGameStateContext_Ability(Context).InputContext.SourceObject.ObjectID));

	EventManager.TriggerEvent('UnitRemovedFromPlay', UnitState, UnitState, NewGameState);

	return NewGameState;
}

simulated function FollowerDefeatedEscape_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata ActionMetadata;
	local X2Action_PlayEffect EffectAction;
	local X2Action_Delay DelayAction;
	
	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	//Configure the visualization track for the shooter
	//****************************************************************************************
	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(Context.InputContext.SourceObject.ObjectID);
	
	EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false));
	EffectAction.EffectName = "FX_Chosen_Teleport.P_Chosen_Teleport_Out_w_Sound";
	EffectAction.EffectLocation = ActionMetadata.VisualizeActor.Location;
	EffectAction.bWaitForCompletion = false;

	DelayAction = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTree(ActionMetadata, Context, false));
	DelayAction.Duration = 0.25;

	class'X2Action_RemoveUnit'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, DelayAction);
	//****************************************************************************************
}

static function X2AbilityTemplate CreateNoLootAndCorpseAbility()
{
	local X2AbilityTemplate Template;
	local X2Effect_NoLootAndCorpse NoLootAndCorpseEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'NoLootAndCorpse');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	NoLootAndCorpseEffect = new class'X2Effect_NoLootAndCorpse';
	NoLootAndCorpseEffect.BuildPersistentEffect(1, true, true, true);
	NoLootAndCorpseEffect.bRemoveWhenTargetDies = true;
	Template.AddShooterEffect(NoLootAndCorpseEffect);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

//Taken from Iridar's Slag/Singe Ability
static function EventListenerReturn AbilityTriggerEventListener_PrimaryDaze(
	Object EventData,
	Object EventSource,
	XComGameState GameState,
	Name EventID,
	Object CallbackData)
{
	return HandleDazeEventTrigger('Primary_Daze', EventData, EventSource, GameState);
}

static function EventListenerReturn AbilityTriggerEventListener_SecondaryDaze(
	Object EventData,
	Object EventSource,
	XComGameState GameState,
	Name EventID,
	Object CallbackData)
{
	return HandleDazeEventTrigger('Secondary_Daze', EventData, EventSource, GameState);
}

static function EventListenerReturn HandleDazeEventTrigger(
	name DazeName,
	Object EventData,
	Object EventSource,
	XComGameState GameState)
{
	local XComGameStateContext_Ability		AbilityContext;
	local XComGameState_Ability				AbilityState, SlagAbilityState;
	local XComGameState_Unit				SourceUnit, TargetUnit;
	local XComGameStateContext				FindContext;
	local int								VisualizeIndex;
	local XComGameStateHistory				History;
	local X2AbilityTemplate					AbilityTemplate;
	local X2Effect							Effect;
	local X2AbilityMultiTarget_BurstFire	BurstFire;
	local bool bDealsDamage;
	local int NumShots;
	local int i;

	History = `XCOMHISTORY;

	AbilityState = XComGameState_Ability(EventData);	// Ability State that triggered this Event Listener
	SourceUnit = XComGameState_Unit(EventSource);
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	TargetUnit = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	AbilityTemplate = AbilityState.GetMyTemplate();

	if (AbilityState != none && SourceUnit != none && TargetUnit != none && AbilityTemplate != none && AbilityContext.InputContext.ItemObject.ObjectID != 0)
	{	
		//	try to find Singe ability on the source weapon of the same ability
		SlagAbilityState = XComGameState_Ability(History.GetGameStateForObjectID(SourceUnit.FindAbility(DazeName, AbilityContext.InputContext.ItemObject).ObjectID));

		//	if this is an offensive ability that actually hit the enemy, the same weapon has a Singe ability, and the enemy is still alive
		if (SlagAbilityState != none && AbilityContext.IsResultContextHit() && AbilityState.GetMyTemplate().Hostility == eHostility_Offensive && TargetUnit.IsAlive())
		{
			//	check if the ability deals damage
			foreach AbilityTemplate.AbilityTargetEffects(Effect)
			{
				if (X2Effect_ApplyWeaponDamage(Effect) != none)
				{
					bDealsDamage = true;
					break;
				}
			}

			if (bDealsDamage)
			{
				//	account for abilities like Fan Fire and Cyclic Fire that take multiple shots within one ability activation
				NumShots = 1;
				BurstFire = X2AbilityMultiTarget_BurstFire(AbilityTemplate.AbilityMultiTargetStyle);
				if (BurstFire != none)
				{
					NumShots += BurstFire.NumExtraShots;
				}
				//	
				for (i = 0; i < NumShots; i++)
				{
					//	pass the Visualize Index to the Context for later use by Merge Vis Fn
					VisualizeIndex = GameState.HistoryIndex;
					FindContext = AbilityContext;
					while (FindContext.InterruptionHistoryIndex > -1)
					{
						FindContext = History.GetGameStateFromHistory(FindContext.InterruptionHistoryIndex).GetContext();
						VisualizeIndex = FindContext.AssociatedState.HistoryIndex;
					}
					//`LOG("Singe activated by: " @ AbilityState.GetMyTemplateName() @ "from: " @ AbilityState.GetSourceWeapon().GetMyTemplateName() @ "Singe source weapon: " @ SlagAbilityState.GetSourceWeapon().GetMyTemplateName(),, 'IRISINGE');
					SlagAbilityState.AbilityTriggerAgainstSingleTarget(AbilityContext.InputContext.PrimaryTarget, false, VisualizeIndex);
				}
			}
		}
	}

	return ELR_NoInterrupt;
}


function XComGameState ChosenSummonFollowers_BuildGameState(XComGameStateContext Context)
{
	local XComGameState NewGameState;
	local PodSpawnInfo SpawnInfo;
	local XComAISpawnManager SpawnManager;
	local int AlertLevel, ForceLevel;
	local XComGameStateHistory History;
	local XComGameState_BattleData BattleData;
	local XComGameState_MissionSite MissionSiteState;
	local XComGameState_Unit UnitState;
	local TTile ChosenTileLocation;
	local XComWorldData WorldData;
	local Name FollowerEncounterGroupID;
	local X2EventManager EventManager;
	local Object UnitObject;

	EventManager = `XEVENTMGR;
	History = `XCOMHISTORY;

	NewGameState = History.CreateNewGameState(true, Context);
	TypicalAbility_FillOutGameState(NewGameState);

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComGameStateContext_Ability(Context).InputContext.SourceObject.ObjectID));
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	ForceLevel = BattleData.GetForceLevel();
	AlertLevel = BattleData.GetAlertLevel();
	FollowerEncounterGroupID = GetReinforcementGroupName(AlertLevel);

	if (FollowerEncounterGroupID != '')
	{
		SpawnInfo.EncounterID = FollowerEncounterGroupID;

		WorldData = `XWORLD;
		UnitState.GetKeystoneVisibilityLocation(ChosenTileLocation);
		SpawnInfo.SpawnLocation = WorldData.GetPositionFromTileCoordinates(ChosenTileLocation);

		if (BattleData.m_iMissionID > 0)
		{
			MissionSiteState = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));

			if (MissionSiteState != None && MissionSiteState.SelectedMissionData.SelectedMissionScheduleName != '')
			{
				AlertLevel = MissionSiteState.SelectedMissionData.AlertLevel;
				ForceLevel = MissionSiteState.SelectedMissionData.ForceLevel;
			}
		}

		// build a character selection that will work at this location
		SpawnManager = `SPAWNMGR;
		SpawnManager.SelectPodAtLocation(SpawnInfo, ForceLevel, AlertLevel, BattleData.ActiveSitReps);
		SpawnManager.SpawnPodAtLocation(NewGameState, SpawnInfo, false, false, true);

		if (SpawnInfo.SpawnedPod.m_arrUnitIDs.Length > 0)
		{
			UnitObject = UnitState;
			EventManager.RegisterForEvent(UnitObject, 'ChosenSpawnReinforcementsComplete', UnitState.OnSpawnReinforcementsComplete, ELD_OnStateSubmitted, , UnitState);
			EventManager.TriggerEvent('ChosenSpawnReinforcementsComplete', SpawnInfo.SpawnedPod.GetGroupState(), UnitState, NewGameState);
		}
	}

	return NewGameState;
}

simulated function ChosenSummonFollowers_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local VisualizationActionMetadata EmptyTrack, ActionMetadata, NewUnitActionMetadata;
	local StateObjectReference InteractingUnitRef;
	local XComGameStateContext_Ability  AbilityContext;
	local X2Action_CameraLookAt LookAtAction;
	local XComGameState_Unit UnitState;
	local array<XComGameState_Unit> FreshlySpawnedUnitStates;
	local TTile SpawnedUnitTile;
	local X2Action_RevealArea RevealAreaAction;
	local X2Action_PlayAnimation PlayAnimAction;
	local XComWorldData WorldData;
	local X2Action_PlayEffect SpawnEffectAction;
	local X2Action_Delay RandomDelay;
	local float OffsetVisDuration;
	local array<X2Action>					LeafNodes;
	local XComContentManager ContentManager;
	local XComGameStateVisualizationMgr VisualizationMgr;
	local X2Action_MarkerNamed SyncAction;

	VisualizationMgr = `XCOMVISUALIZATIONMGR;
	ContentManager = `CONTENT;
	History = `XCOMHISTORY;

	TypicalAbility_BuildVisualization(VisualizeGameState);
	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = AbilityContext.InputContext.SourceObject;
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(InteractingUnitRef.ObjectID));

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if (History.GetGameStateForObjectID(UnitState.ObjectID, , VisualizeGameState.HistoryIndex - 1) == None)
		{
			FreshlySpawnedUnitStates.AddItem(UnitState);
		}
	}

	// if any units spawned in as part of this action, visualize the spawning as part of this sequence
	if (FreshlySpawnedUnitStates.Length > 0)
	{
		WorldData = `XWORLD;

		ActionMetadata = EmptyTrack;
		ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
		ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

		// Pan to Chosen if not already there.
		LookAtAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, ActionMetadata.LastActionAdded));
		LookAtAction.UseTether = false;
		LookAtAction.LookAtObject = ActionMetadata.StateObject_NewState;
		LookAtAction.BlockUntilActorOnScreen = true;

		RevealAreaAction = X2Action_RevealArea(class'X2Action_RevealArea'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, ActionMetadata.LastActionAdded));
		RevealAreaAction.ScanningRadius = class'XComWorldData'.const.WORLD_StepSize * 5.0f;
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(InteractingUnitRef.ObjectID));
		UnitState.GetKeystoneVisibilityLocation(SpawnedUnitTile);
		RevealAreaAction.TargetLocation = WorldData.GetPositionFromTileCoordinates(SpawnedUnitTile);
		RevealAreaAction.bDestroyViewer = false;
		RevealAreaAction.AssociatedObjectID = InteractingUnitRef.ObjectID;
		
		// Trigger the Chosen's narrative line for summoning
		class'XComGameState_NarrativeManager'.static.BuildVisualizationForDynamicNarrative(VisualizeGameState, false, 'ChosenSummonBegin', ActionMetadata.LastActionAdded);

		// play an animation on the chosen showing them summoning in their followers
		PlayAnimAction = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, , ActionMetadata.LastActionAdded));
		PlayAnimAction.bFinishAnimationWait = true;
		PlayAnimAction.Params.AnimName = 'HL_Summon';

		SyncAction = X2Action_MarkerNamed(class'X2Action_MarkerNamed'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, ActionMetadata.LastActionAdded));
		SyncAction.SetName("SpawningStart");
		SyncAction.AddInputEvent('Visualizer_AbilityHit');

		foreach FreshlySpawnedUnitStates(UnitState)
		{
			if (UnitState.GetVisualizer() == none)
			{
				UnitState.FindOrCreateVisualizer();
				UnitState.SyncVisualizer();

				//Make sure they're hidden until ShowSpawnedUnit makes them visible (SyncVisualizer unhides them)
				XGUnit(UnitState.GetVisualizer()).m_bForceHidden = true;
			}

			NewUnitActionMetadata = EmptyTrack;
			NewUnitActionMetadata.StateObject_OldState = None;
			NewUnitActionMetadata.StateObject_NewState = UnitState;
			NewUnitActionMetadata.VisualizeActor = History.GetVisualizer(UnitState.ObjectID);

			// if multiple units are spawning, apply small random delays between each
			if (UnitState != FreshlySpawnedUnitStates[0])
			{
				RandomDelay = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTree(NewUnitActionMetadata, AbilityContext, false, SyncAction));
				OffsetVisDuration += 0.5f + `SYNC_FRAND() * 0.5f;
				RandomDelay.Duration = OffsetVisDuration;
			}
			
			X2Action_ShowSpawnedUnit(class'X2Action_ShowSpawnedUnit'.static.AddToVisualizationTree(NewUnitActionMetadata, AbilityContext, false, ActionMetadata.LastActionAdded));

			UnitState.GetKeystoneVisibilityLocation(SpawnedUnitTile);

			SpawnEffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(NewUnitActionMetadata, AbilityContext, false, ActionMetadata.LastActionAdded));
			SpawnEffectAction.EffectName = ContentManager.ChosenReinforcementsEffectPathName;
			SpawnEffectAction.EffectLocation = WorldData.GetPositionFromTileCoordinates(SpawnedUnitTile);
			SpawnEffectAction.bStopEffect = false;
		}

		VisualizationMgr.GetAllLeafNodes(VisualizationMgr.BuildVisTree, LeafNodes);

		RevealAreaAction = X2Action_RevealArea(class'X2Action_RevealArea'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, none, LeafNodes));
		RevealAreaAction.bDestroyViewer = true;
		RevealAreaAction.AssociatedObjectID = InteractingUnitRef.ObjectID;
	}
}

static function name GetReinforcementGroupName(int AlertLevel)
{
	local name GroupName;
	if (default.CHOSEN_SUMMON_RNF_DATA.Length == 0)
	{
		return '';
	}

	if (AlertLevel < 0)
	{
		GroupName = default.CHOSEN_SUMMON_RNF_DATA[0];
	}
	else if (AlertLevel >= default.CHOSEN_SUMMON_RNF_DATA.Length)
	{
		GroupName = default.CHOSEN_SUMMON_RNF_DATA[default.CHOSEN_SUMMON_RNF_DATA.Length - 1];
	}
	else
	{
		GroupName = default.CHOSEN_SUMMON_RNF_DATA[AlertLevel];
	}

	return GroupName;
}

defaultproperties
{
	ExtractKnowledgeMarkSourceEffectName="ExtractKnowledgeMarkSourceEffect"
	ExtractKnowledgeMarkTargetEffectName="ExtractKnowledgeMarkTargetEffect"

	ChosenSummonContextDesc="ChosenSummonContext"
}
