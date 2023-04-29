// Fill out your copyright notice in the Description page of Project Settings.


#include "CharacterMovement.h"
#include "Blueprint/WidgetBlueprintLibrary.h"

// Sets default values
ACharacterMovement::ACharacterMovement()
{
 	// Set this character to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

	AutoPossessPlayer = EAutoReceiveInput::Player0;

	bUseControllerRotationYaw = false;

	//Creating camera and spring arm for 3rd person perspective
	cam = CreateDefaultSubobject<UCameraComponent>(TEXT("Camera"));

	arm = CreateDefaultSubobject<USpringArmComponent>(TEXT("SpringArm"));

	armRoot = CreateDefaultSubobject<UActorComponent>(TEXT("ArmRoot"));

	//Find Pause Widget

	static ConstructorHelpers::FClassFinder<UUserWidget> pauseWidgetClassFound(TEXT("WidgetBlueprint'/Game/PauseMenu.PauseMenu_C'"));

	if (pauseWidgetClassFound.Class != nullptr) {
		pauseWidgetClass = pauseWidgetClassFound.Class;
	}
	
}


// Called when the game starts or when spawned
void ACharacterMovement::BeginPlay()
{
	Super::BeginPlay();

	//Connecting the arm to the actor and defining arm parameters
	arm->AttachToComponent(RootComponent, FAttachmentTransformRules::KeepRelativeTransform);
	arm->TargetArmLength = customTargetArmLength;
	arm->SetWorldRotation(FRotator(customCameraPitch, 0.f, 0.f));
	arm->bInheritYaw = false;

	//Camera lag

	arm->bEnableCameraLag = true;
	arm->CameraLagSpeed = customCameraLag;
	arm->CameraLagMaxDistance = customCameraLagMaxDistance;

	arm->bEnableCameraRotationLag = true;
	arm->CameraRotationLagSpeed = customCameraRotationLagSpeed;
	arm->CameraLagMaxTimeStep = customCameraRotationLagTime;

	//Connecting camera to arm
	cam->AttachToComponent(arm, FAttachmentTransformRules::KeepWorldTransform, USpringArmComponent::SocketName);

	//Setting camera relative values to 0
	cam->SetRelativeLocation(FVector(0,0,0));
	cam->SetRelativeRotation(FQuat(0,0,0,0));

	//Default Movement
	isWalking = true;
	isSneaking = false;
	jumping = false;
	bUseControllerRotationPitch = true;
	bUseControllerRotationRoll = true;

	//Sets the player to be alive at the start... For obvious reasons. Also, default stats.

	isLiving = true;
	health = defaultHealth;
	stamina = defaultStamina;


}

// Called every frame
void ACharacterMovement::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);


	if (jumping) {
		Jump();
	}


}

float ACharacterMovement::getHealthPercent() {
	return (float)health / defaultHealth;
}

// Called to bind functionality to input
void ACharacterMovement::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

	//Binding inputs
	InputComponent->BindAxis("MoveX", this, &ACharacterMovement::HorizontalMove);
	InputComponent->BindAxis("MoveY", this, &ACharacterMovement::VerticalMove);
	InputComponent->BindAxis("LookX", this, &ACharacterMovement::HorizontalRot);
	InputComponent->BindAxis("LookY", this, &ACharacterMovement::VerticalRot);

	InputComponent->BindAction("Jump", IE_Pressed, this, &ACharacterMovement::CheckJump);
	InputComponent->BindAction("Jump", IE_Released, this, &ACharacterMovement::CheckJump);

	InputComponent->BindAction("Sprint", IE_Pressed, this, &ACharacterMovement::Sprint);
	InputComponent->BindAction("Sprint", IE_Released, this, &ACharacterMovement::Sprint);

	InputComponent->BindAction("Sneak", IE_Pressed, this, &ACharacterMovement::Sneak);

	InputComponent->BindAction("Pause", IE_Pressed, this, &ACharacterMovement::Pause);
}

//Defining what the inputs binded above do

void ACharacterMovement::Pause() {

	CreateWidget<UUserWidget>(this, pauseWidgetClass, FName(TEXT("PauseMenu")));
}

void ACharacterMovement::HorizontalMove(float value) {

	if (value) {
		sidewaysInput = value;
	}
	else {
		sidewaysInput = 0;
	}

	magnitudeValue = sqrt(sidewaysInput * sidewaysInput + forwardInput * forwardInput);

	if (value && magnitudeValue > 1) {
		normalizedSidewaysValue = sidewaysInput/magnitudeValue;
	}
	else {
		normalizedSidewaysValue = sidewaysInput;
	}
	if (value && isSneaking) {
		AddMovementInput(cam->GetRightVector(), normalizedSidewaysValue * stealthMultiplier);
	}
	else if (value && isWalking) {
		AddMovementInput(cam->GetRightVector(), normalizedSidewaysValue * sprintSpeedMultiplier);
	}
	else {
		AddMovementInput(cam->GetRightVector(), normalizedSidewaysValue);
	}
	//Moves the actor to the side based on horizontal input

	//MatchGround();
}

void ACharacterMovement::VerticalMove(float value) {

	//UE_LOG(LogTemp, Log, TEXT("Vertical Value: %f"), value);

	if (value) {
		forwardInput = value;
	}
	else {
		forwardInput = 0;
	}

	magnitudeValue = sqrt(sidewaysInput * sidewaysInput + forwardInput * forwardInput);

	if (value && magnitudeValue > 1) {
		normalizedForwardValue = forwardInput / magnitudeValue;
	}
	else {
		normalizedForwardValue = forwardInput;
	}

	if (value && isSneaking) {
		AddMovementInput(cam->GetForwardVector(), normalizedForwardValue * stealthMultiplier);
	}
	else if (value && isWalking) {
		AddMovementInput(cam->GetForwardVector(), normalizedForwardValue * sprintSpeedMultiplier);
	}
	else {
		AddMovementInput(cam->GetForwardVector(), normalizedForwardValue);
	}
	//Moves the actor forward or backward based on vertical input

	//MatchGround();
}
void ACharacterMovement::HorizontalRot(float value) {
	if (value) {
		arm->AddWorldRotation(FRotator(0, value, 0));
	}
}
void ACharacterMovement::VerticalRot(float value) {
	if (value) {
		float temp = arm->GetRelativeRotation().Pitch + value;
		if (temp < customCameraRotationMax && temp > customCameraRotationMin) {
			arm->AddLocalRotation(FRotator(value, 0, 0));
		}
	}
}

void ACharacterMovement::CheckJump() {
	if (jumping) {
		jumping = false;
	}
	else {
		jumping = true;
	}
}

void ACharacterMovement::Sprint() {
	isWalking = !isWalking;
	if (isSneaking) {
		isSneaking = false;
	}
}
void ACharacterMovement::Sneak() {
	if (isWalking) {
		isSneaking = !isSneaking;
	}
}

/*void ACharacterMovement::MatchGround() {
	FHitResult* hit = new FHitResult();
	FVector start = GetActorLocation();
	FVector end = (-GetActorUpVector() * 500) + start;
	FVector up = GetActorUpVector();
	FQuat colQuat = GetActorQuat();
	FCollisionQueryParams col = FCollisionQueryParams();
	UCapsuleComponent* capsuleComponent = ACharacter::GetCapsuleComponent();
	FCollisionShape capsule = capsuleComponent.GetCollisionShape();
	col.AddIgnoredActor(this);
	FVector groundNormal;
	if (GetWorld()->SweepSingleByChannel(*hit, start, end, colQuat, ECollisionChannel::ECC_WorldStatic, capsule, col)) {
		DrawDebugLine(GetWorld(), start, end, FColor::Orange, false);
		if (hit->GetActor() != NULL) {
			UE_LOG(LogTemp, Log, TEXT("Hit found: %s"), *hit->GetComponent()->GetName());
			groundNormal = hit->ImpactNormal;
			UE_LOG(LogTemp, Log, TEXT("Normal found: %s"), *groundNormal.ToString())
		}
	}

	float DotProduct = FVector::DotProduct(up, groundNormal);
	float angle = acosf(DotProduct);
	if (DotProduct != 1) {
		FVector axis = FVector::CrossProduct(up, groundNormal);
		axis.Normalize();

		FQuat quat = FQuat(axis, angle);
		FQuat originalQuat = GetActorQuat();

		FQuat changeQuat = quat * originalQuat;

		FRotator changeRotation = changeQuat.Rotator();

		FRotator currentRotation = GetActorRotation();
		FRotator rotateMatch = FRotator(changeRotation.Pitch, changeRotation.Yaw, changeRotation.Roll);
		APlayerController* playerController = UGameplayStatics::GetPlayerController(this, 0);
		playerController->SetControlRotation(rotateMatch);
	}

//	SetActorRotation(rotateMatch, ETeleportType::None);
	delete hit;
}*/

