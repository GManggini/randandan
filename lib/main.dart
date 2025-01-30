import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'gyroscope_manager.dart';
import 'game_over.dart';
import 'main_menu.dart';
import 'login_overlay.dart';
import 'sign_up.dart';
import 'list_user_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    GameWidget(
      game: Randandan(),
      overlayBuilderMap: {
        'mainMenu': (context, game) => MainMenu(
              onStartGame: () {
                (game as Randandan).overlays.remove('mainMenu');
                game.resumeEngine();
              },
              onLoginPressed: () {
                (game as Randandan).overlays.add('loginOverlay');
              },
              onSignUpPressed: () {
                (game as Randandan).overlays.add('signUpOverlay');
              },
              onListUsersPressed: () {
                (game as Randandan).overlays.add('listUsersOverlay');
              },
            ),
        'loginOverlay': (context, game) => MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.transparent,
                body: LoginOverlay(
                  onLoginSuccess: () {
                    (game as Randandan).overlays.remove('loginOverlay');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Login realizado com sucesso!')),
                    );
                  },
                  onBack: () {
                    (game as Randandan).overlays.remove('loginOverlay');
                  },
                ),
              ),
            ),
        'signUpOverlay': (context, game) => MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.transparent,
                body: SignUpOverlay(
                  onSignUpSuccess: () {
                    (game as Randandan).overlays.remove('signUpOverlay');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Conta criada com sucesso!')),
                    );
                  },
                  onBack: () {
                    (game as Randandan).overlays.remove('signUpOverlay');
                  },
                ),
              ),
            ),
        'listUsersOverlay': (context, game) => MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.transparent,
                body: ListUsersOverlay(
                  onBack: () {
                    (game as Randandan).overlays.remove('listUsersOverlay');
                  },
                ),
              ),
            ),
        'gameOverMenu': (context, game) => GameOverMenu(
              score: (game as Randandan).score,
              onRestart: () {
                game.resetGame();
                game.overlays.remove('gameOverMenu');
              },
              onQuit: () {
                game.resetGame();
                game.pauseEngine();
                game.overlays.remove('gameOverMenu');
                game.overlays.add('mainMenu');
              },
              saveScore: (score) => game._saveScore(score),
            ),
      },
      initialActiveOverlays: const ['mainMenu'],
    ),
  );
}

class Randandan extends FlameGame with PanDetector, HasCollisionDetection {
  late Player player;
  late GyroscopeManager? _gyroscopeManager;
  int score = 0;
  late TextComponent _scoreText;

  Future<void> _saveScore(int score) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'score': score});
    }
  }

  void resetGame() {
    score = 0;
    player = Player(); // Recria o player
    add(player); // Adiciona o player ao jogo

    // Remove todos os inimigos existentes
    children.whereType<Enemy>().forEach((enemy) => enemy.removeFromParent());

    // Remove todos os spawners existentes
    children
        .whereType<SpawnComponent>()
        .forEach((spawner) => spawner.removeFromParent());

    // Reinicia o spawn de inimigos
    add(
      SpawnComponent(
        factory: (index) => Enemy(),
        period: 1,
        area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
      ),
    );

    // Reinicia o jogo
    resumeEngine();
  }

  @override
  Future<void> onLoad() async {
    pauseEngine();

    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('road.png'),
      ],
      baseVelocity: Vector2(0, -55),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(0, 5),
    );
    add(parallax);

    player = Player();
    add(player);

    _gyroscopeManager = GyroscopeManager(sensitivity: 50);
    _gyroscopeManager?.gyroscopeStream.listen((data) {
      final zMovement = data['z']!;
      player.move(Vector2(zMovement, 0));
    });

    add(
      SpawnComponent(
        factory: (index) => Enemy(),
        period: 1 /*- (score / 1000)*/,
        area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
      ),
    );
    _scoreText = TextComponent(
      text: "Pontuação: $score",
      position: Vector2(10, 700),
      textRenderer:
          TextPaint(style: TextStyle(fontSize: 24, color: Colors.white)),
    );

    add(_scoreText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    score += (300 * dt).toInt();
    _scoreText.text = "Pontuação: $score";
  }

  @override
  void onRemove() {
    _gyroscopeManager?.dispose();
    super.onRemove();
  }
}

class Player extends SpriteAnimationComponent with HasGameReference<Randandan> {
  Player()
      : super(
          size: Vector2(80, 130),
          anchor: Anchor.center,
        );

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
  }

  void move(Vector2 delta) {
    position.add(delta);
    position.x = position.x.clamp(0 + width / 2, game.size.x - width / 2);
    position.y = position.y.clamp(game.size.y - height, game.size.y - height);
  }
}

class Enemy extends SpriteAnimationComponent
    with HasGameReference<Randandan>, CollisionCallbacks {
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
      // Remove o player e o inimigo
      other.removeFromParent();
      removeFromParent();

      // Adiciona a explosão no local da colisão
      game.add(Explosion(position: position));
    }
  }
}

class Explosion extends SpriteAnimationComponent
    with HasGameReference<Randandan> {
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

    // Callback quando a animação terminar
    animationTicker?.onComplete = () {
      game.pauseEngine();
      game.overlays.add('gameOverMenu');
    };
  }
}
