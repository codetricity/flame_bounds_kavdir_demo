import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with HasDraggables {
  SpriteComponent background = SpriteComponent();
  late SpriteAnimationComponent ghost;
  late final JoystickComponent joystick;
  late SpriteComponent ghostTest;

  bool ghostFlipped = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final ghostImage = await images.load('ghost_sheet.png');

    //Loading background
    add(
      background
        ..sprite = await loadSprite('manhattan.jpg')
        ..size = size,
    );

    //adding joystick for controlling to Ghost
    final buttonPaint = BasicPalette.red.withAlpha(150).paint();
    final backgroundPaint = BasicPalette.black.withAlpha(100).paint();

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: buttonPaint),
      background: CircleComponent(radius: 100, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);

    //Loading ghost character

    final ghostAnimation = SpriteAnimation.fromFrameData(
      ghostImage,
      SpriteAnimationData.sequenced(
        amount: 15,
        stepTime: 0.05,
        textureSize: Vector2(300, 200),
      ),
    );
    ghost = SpriteAnimationComponent()
      ..animation = ghostAnimation
      ..size = Vector2(150, 100)
      ..position = Vector2(500, 250);
    //ghost.flipHorizontallyAroundCenter();
    ghostTest = SpriteComponent.fromImage(ghostImage)
      ..size = Vector2.all(120)
      ..position = Vector2(500, 250);
    add(ghost);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final bool moveUp = joystick.relativeDelta[1] < 0;
    final bool moveDown = joystick.relativeDelta[1] > 0;
    final bool moveLeft = joystick.relativeDelta[0] < 0;
    final bool moveRight = joystick.relativeDelta[0] > 0;

    final double ghostVectorX = (joystick.relativeDelta * 300 * dt)[0];
    final double ghostVectorY = (joystick.relativeDelta * 300 * dt)[1];

    //When ghost is moving on X direction
    if ((moveLeft && ghost.x > 0) || (moveRight && ghost.x < size[0])) {
      ghost.position.add(Vector2(ghostVectorX, 0));
      print('${size[0]} ${ghost.position[0]}');
    }
    //when ghost is moving on Y direction
    if ((moveUp && ghost.y > 0) ||
        (moveDown && ghost.y < size[1] - ghost.height)) {
      ghost.position.add(Vector2(0, ghostVectorY));
    }

    if (joystick.relativeDelta[0] < 0 && ghostFlipped) {
      ghostFlipped = false;
      ghost.flipHorizontallyAroundCenter();
    }
    if (joystick.relativeDelta[0] > 0 && !ghostFlipped) {
      ghostFlipped = true;
      ghost.flipHorizontallyAroundCenter();
    }
  }
}
