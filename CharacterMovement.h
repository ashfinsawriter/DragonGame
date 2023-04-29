// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Components/InputComponent.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "GameFramework/PlayerController.h"
#include "GameFramework/Character.h"
#include "Blueprint/UserWidget.h"
#include "Kismet/GameplayStatics.h"
#include "DrawDebugHelpers.h"
#include "CharacterMovement.generated.h"

UCLASS()
class DRAGONGAME_API ACharacterMovement : public ACharacter
{
	GENERATED_BODY()

public:
	// Sets default values for this character's properties
	ACharacterMovement();

	//Public values to adjust in editor
	UPROPERTY(Category = "Camera", EditAnywhere, meta = (ClampMin = "0", UIMin = "0"))
		float customTargetArmLength;
	UPROPERTY(Category = "Camera", EditAnywhere, meta = (ClampMin = "-180", ClampMax = "180", UIMin = "-180", UIMax = "180"))
		float customCameraPitch;
	UPROPERTY(Category = "Camera", EditAnywhere, meta = (ClampMin = "0", UIMin = "0"))
		float customCameraLag;
	UPROPERTY(Category = "Camera", EditAnywhere, meta = (ClampMin = "0", UIMin = "0"))
		float customCameraLagMaxDistance;
	UPROPERTY(Category = "Camera", EditAnywhere, meta = (ClampMin = "0", UIMin = "0"))
		float customCameraRotationLagSpeed;
	UPROPERTY(Category = "Camera", EditAnywhere, meta = (ClampMin = "0", UIMin = "0"))
		float customCameraRotationLagTime;
	UPROPERTY(Category = "Camera", EditAnywhere, meta = (ClampMin = "-180", ClampMax = "180", UIMin = "-180", UIMax = "180"))
		float customCameraRotationMax;
	UPROPERTY(Category = "Camera", EditAnywhere, meta = (ClampMin = "-180", ClampMax = "180", UIMin = "-180", UIMax = "180"))
		float customCameraRotationMin;
	UPROPERTY(Category = "Character Movement: Walking", EditAnywhere, meta = (ClampMin = "0", UIMin = "0"))
		float turnTime;
	UPROPERTY(Category = "Character Stats", BlueprintReadWrite, EditAnywhere, meta = (ClampMin = "0", UIMin = "0"))
		int defaultHealth;
	UPROPERTY(Category = "Character Stats", BlueprintReadWrite, EditAnywhere, meta = (ClampMin = "0", UIMin = "0"))
		int defaultStamina;

	UPROPERTY(BlueprintReadWrite, EditAnywhere)
		int health;
	UPROPERTY(BlueprintReadWrite, EditAnywhere)
		int stamina;

public:
	//Returning current health as percentage
	UFUNCTION(BlueprintCallable)
		float getHealthPercent();

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

public:	
	// Called every frame
	virtual void Tick(float DeltaTime) override;

	// Called to bind functionality to input
	virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

private:
	//Declaring inputs
	void HorizontalMove(float value);
	void VerticalMove(float value);
	void HorizontalRot(float value);
	void VerticalRot(float value);
	void CheckJump();
	void Sprint();
	void Sneak();
	void Pause();

	//Additional functions
	void MatchGround();

	//Widget
	UPROPERTY()
		TSubclassOf<UUserWidget> pauseWidgetClass;

	UPROPERTY()
		UUserWidget* PauseWidget;

	//Generating components
	UPROPERTY()
		UCameraComponent* cam;
	UPROPERTY()
		USpringArmComponent* arm;
	UPROPERTY()
		UActorComponent* armRoot;

	//Variables

	UPROPERTY()
		float sidewaysInput;
	UPROPERTY()
		float forwardInput;
	UPROPERTY()
		float normalizedForwardValue;
	UPROPERTY()
		float normalizedSidewaysValue;
	UPROPERTY()
		float magnitudeValue;

	UPROPERTY()
		float sprintSpeedMultiplier = 0.5f;
	UPROPERTY()
		float stealthMultiplier = 0.25f;
	UPROPERTY()
		bool isWalking;
	UPROPERTY()
		bool isSneaking;
	UPROPERTY()
		bool jumping;

	UPROPERTY()
		bool isLiving;
};
