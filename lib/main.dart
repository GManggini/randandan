import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'gyroscope_manager.dart';

void main() {
  runApp(GameWidget(game: SpaceShooterGame()));
}

class SpaceShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection {
  late Player player;
  late GyroscopeManager? _gyroscopeManager;

  @override
  Future<void> onLoad() async {
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('road.png'),
        // ParallaxImageData('stars.png'),
        //ParallaxImageData('stars_2.png'),
      ],
      baseVelocity: Vector2(0, -35),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(0, 5),
    );
    add(parallax);

    player = Player();
    add(player);

    _gyroscopeManager = GyroscopeManager(sensitivity: 50);
    _gyroscopeManager?.gyroscopeStream.listen((data) {
      final zMovement = data['z']!;
      //final xMovement = data['x']!;

      player.move(Vector2(zMovement, 0)); // xMovement));
    });

    add(
      SpawnComponent(
        factory: (index) {
          return Enemy();
        },
        period: 1,
        area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
      ),
    );
  }

  @override
  void onRemove() {
    _gyroscopeManager?.dispose();
    super.onRemove();
  }

  // @override
  // void onPanUpdate(DragUpdateInfo info) {
  //   player.move(info.delta.global);
  // }

  // @override
  // void onPanStart(DragStartInfo info) {
  //   player.startShooting();
  // }

  // @override
  // void onPanEnd(DragEndInfo info) {
  //   player.stopShooting();
  // }
}

class Player extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Player()
      : super(
          size: Vector2(80, 130),
          anchor: Anchor.center,
        );

  // late final SpawnComponent _bulletSpawner;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'player.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2(32, 48),
      ),
    );
    add(RectangleHitbox());
    position = game.size / 2;

    // _bulletSpawner = SpawnComponent(
    //   period: 0.2,
    //   selfPositioning: true,
    //   factory: (index) {
    //     return Bullet(
    //       position: position +
    //           Vector2(
    //             0,
    //             -height / 2,
    //           ),
    //     );
    //   },
    //   autoStart: false,
    // );

    // game.add(_bulletSpawner);
  }

  void move(Vector2 delta) {
    position.add(delta);
    position.x = position.x.clamp(0 + width / 2, game.size.x - width / 2);
    // position.y = position.y.clamp(0 + height / 2, game.size.y - height / 2);
  }

  // void startShooting() {
  //   _bulletSpawner.timer.start();
  // }

  // void stopShooting() {
  //   _bulletSpawner.timer.stop();
  // }
}

// class Bullet extends SpriteAnimationComponent
//     with HasGameReference<SpaceShooterGame> {
//   Bullet({
//     super.position,
//   }) : super(
//           size: Vector2(20, 40),
//           anchor: Anchor.center,
//         );

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();

//     animation = await game.loadSpriteAnimation(
//       'bullet.png',
//       SpriteAnimationData.sequenced(
//         amount: 4,
//         stepTime: 0.2,
//         textureSize: Vector2(8, 16),
//       ),
//     );
//     // add(
//     //   RectangleHitbox(
//     //     collisionType: CollisionType.passive,
//     //   ),
//     // );
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);

//     position.y += dt * -500;

//     if (position.y < -height) {
//       removeFromParent();
//     }
//   }
// }

class Enemy extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  Enemy({
    super.position,
  }) : super(
          size: Vector2.all(enemySize),
          anchor: Anchor.center,
        );

  static const enemySize = 50.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'enemy.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .2,
        textureSize: Vector2.all(16),
      ),
    );
    add(
      RectangleHitbox(
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += dt * 300;

    if (position.y > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      removeFromParent();
      other.removeFromParent();
      game.add(Explosion(position: position));
    }
  }
}

class Explosion extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Explosion({
    super.position,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.center,
          removeOnFinish: true,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'explosion.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: .1,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
  }
}
