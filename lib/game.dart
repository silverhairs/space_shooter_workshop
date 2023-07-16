import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

class SpaceShooterGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  SpaceShooterGame() : super();

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(PlayerStarship(position: size / 2));
    add(
      TimerComponent(
        period: 1,
        onTick: () {
          final rand = Random();
          add(
            Enemy(position: Vector2(rand.nextDouble() * size.x, 0)),
          );
        },
        repeat: true,
        autoStart: true,
      ),
    );
  }
}

class PlayerStarship extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame>, KeyboardHandler {
  PlayerStarship({super.position})
      : super(
          size: Vector2.all(96),
          anchor: Anchor.center,
        );

  final Vector2 direction = Vector2.zero();
  static const double speed = 500;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    animation = await gameRef.loadSpriteAnimation(
      'starfighter_1.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2.all(48),
      ),
    );

    add(
      KeyboardListenerComponent(
        keyUp: {
          LogicalKeyboardKey.arrowLeft: (_) {
            direction.x = 0;
            return false;
          },
          LogicalKeyboardKey.arrowRight: (_) {
            direction.x = 0;
            return false;
          },
          LogicalKeyboardKey.arrowUp: (_) {
            direction.y = 0;
            return false;
          },
          LogicalKeyboardKey.arrowDown: (_) {
            direction.y = 0;
            return false;
          }
        },
        keyDown: {
          LogicalKeyboardKey.arrowRight: (_) {
            direction.x = 1;
            return false;
          },
          LogicalKeyboardKey.arrowLeft: (_) {
            direction.x = -1;
            return false;
          },
          LogicalKeyboardKey.arrowUp: (_) {
            direction.y = -1;
            return false;
          },
          LogicalKeyboardKey.arrowDown: (_) {
            direction.y = 1;
            return false;
          },
          LogicalKeyboardKey.space: (_) {
            gameRef.add(Shot(position: position.clone()));
            return false;
          },
        },
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * speed * dt;
  }
}

class Shot extends SpriteAnimationComponent with HasGameRef<SpaceShooterGame> {
  Shot({super.position})
      : super(
          anchor: Anchor.center,
          size: Vector2.all(32),
        );

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    animation = await gameRef.loadSpriteAnimation(
      'shoot_1.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2.all(16),
      ),
    );

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= 400 * dt;
  }
}

class Enemy extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  Enemy({super.position})
      : super(
          anchor: Anchor.center,
          size: Vector2.all(32),
        );

  static const double speed = 100;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    animation = await gameRef.loadSpriteAnimation(
      'alien_1.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2.all(16),
      ),
    );

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Shot) {
      removeFromParent();
      other.removeFromParent();
    }
  }
}
