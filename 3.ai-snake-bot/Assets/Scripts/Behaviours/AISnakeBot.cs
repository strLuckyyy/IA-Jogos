using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "AIBehaviours/SnakeBot")]
public class SnakeBot : AIBehaviour
{
	[Header("Percepção")]
	public float orbDetectionRadius = 15f;     // raio de busca por orbes
	public float dangerDetectionRadius = 8f;   // raio de detecção de cobras inimigas
	public float wallMargin = 3f;              // distância mínima das paredes

	[Header("Movimento")]
	public float turnSpeed = 5f;               // velocidade de rotação
	public float wanderChangeInterval = 2f;    // intervalo para trocar ponto de wander

	private enum BotState { SeekOrb, Flee, Wander }
	private BotState currentState = BotState.Wander;

	private GameLogic gameLogic;               // referência ao GameLogic (acesso ao orbPool e snakes)
	private Bounds worldBounds;                // limites do mundo
	private bool boundsReady = false;


	public override void Init(GameObject own, SnakeMovement ownMove)
	{
		base.Init(own, ownMove);

		gameLogic = Object.FindFirstObjectByType<GameLogic>();

		// Descobre os limites do mundo pelo BoxCollider2D do GameLogic
		if (gameLogic != null)
		{
			BoxCollider2D col = gameLogic.GetComponent<BoxCollider2D>();
			if (col != null)
			{
				worldBounds = col.bounds;
				boundsReady = true;
			}
		}

		// Gera o primeiro ponto de wander
		PickNewWanderPoint();

		// Inicia coroutine que troca o ponto de wander periodicamente
		ownerMovement.StartCoroutine(WanderRoutine());
	}

	public override void Execute()
	{
		if (owner == null) return;

		// 1. PERCEBER
		GameObject nearestOrb = FindNearestOrb();
		GameObject nearestEnemy = FindNearestEnemyHead();
		bool wallDanger = IsNearWall();
		GameObject target = null;

		// 2. DECIDIR (prioridade: Fugir > Buscar Orbe > Vagar)
		if (wallDanger || (nearestEnemy != null && Vector3.Distance(owner.transform.position, nearestEnemy.transform.position) < dangerDetectionRadius))
		{
			currentState = BotState.Flee;
		}
		else if (nearestOrb != null)
		{
			currentState = BotState.SeekOrb;
			target = nearestOrb;
		}
		else
		{
			currentState = BotState.Wander;
		}

		// 3. AGIR
		switch (currentState)
		{
			case BotState.SeekOrb:
				MoveTowards(target.transform.position);
				break;

			case BotState.Flee:
				PerformFlee(nearestEnemy, wallDanger);
				break;

			case BotState.Wander:
				MoveTowards(randomPoint);
				if (Vector3.Distance(owner.transform.position, randomPoint) < 1.5f)
					PickNewWanderPoint();
				break;
		}
	}

	/// <summary>Move suavemente a cobra em direção a um ponto alvo.</summary>
	void MoveTowards(Vector3 destination)
	{
		direction = (destination - owner.transform.position).normalized;
		direction.z = 0f;

		RotateTowardsDirection(direction);

		owner.transform.position = Vector2.MoveTowards(
			owner.transform.position,
			destination,
			ownerMovement.speed * Time.deltaTime
		);
	}

	/// <summary>Calcula direção de fuga e move a cobra para longe do perigo.</summary>
	void PerformFlee(GameObject enemy, bool wallDanger)
	{
		Vector3 fleeDir = Vector3.zero;

		// Foge do inimigo
		if (enemy != null)
			fleeDir += (owner.transform.position - enemy.transform.position).normalized;

		// Foge das paredes
		if (wallDanger && boundsReady)
		{
			Vector3 pos = owner.transform.position;
			Vector3 center = worldBounds.center;
			fleeDir += (pos - center).normalized * 0.5f;
		}

		if (fleeDir == Vector3.zero)
			fleeDir = -direction; // fallback: inverte direção atual

		fleeDir.z = 0f;
		direction = fleeDir.normalized;

		RotateTowardsDirection(direction);

		owner.transform.position = Vector2.MoveTowards(
			owner.transform.position,
			owner.transform.position + direction,
			ownerMovement.speed * Time.deltaTime
		);
	}

	/// <summary>Rotaciona suavemente a cabeça da cobra em direção a um vetor.</summary>
	void RotateTowardsDirection(Vector3 dir)
	{
		float angle = Mathf.Atan2(dir.x, dir.y) * Mathf.Rad2Deg;
		Quaternion targetRotation = Quaternion.AngleAxis(-angle, Vector3.forward);
		owner.transform.rotation = Quaternion.Slerp(
			owner.transform.rotation,
			targetRotation,
			turnSpeed * Time.deltaTime
		);
	}

	// -------------------------------------------------------
	// Percepção – busca de orbes
	// -------------------------------------------------------

	/// <summary>Retorna o orbe ativo mais próximo dentro do raio de detecção.</summary>
	GameObject FindNearestOrb()
	{
		if (gameLogic == null) return null;

		GameObject nearest = null;
		float minDist = orbDetectionRadius;

		foreach (GameObject orb in gameLogic.orbPool)
		{
			if (orb == null || !orb.activeInHierarchy) continue;

			float dist = Vector3.Distance(owner.transform.position, orb.transform.position);
			if (dist < minDist)
			{
				minDist = dist;
				nearest = orb;
			}
		}
		return nearest;
	}

	// -------------------------------------------------------
	// Percepção – detecção de inimigos
	// -------------------------------------------------------

	/// <summary>Retorna a cabeça da cobra inimiga mais próxima.</summary>
	GameObject FindNearestEnemyHead()
	{
		if (gameLogic == null) return null;

		GameObject nearest = null;
		float minDist = dangerDetectionRadius;

		foreach (GameObject snake in gameLogic.snakes)
		{
			// Ignora cobras nulas, mortas ou a própria cobra
			if (snake == null) continue;
			if (snake == owner.transform.parent.gameObject) continue;

			SnakeMovement sm = snake.GetComponentInChildren<SnakeMovement>();
			if (sm == null || sm.isDead) continue;

			float dist = Vector3.Distance(owner.transform.position, sm.transform.position);
			if (dist < minDist)
			{
				minDist = dist;
				nearest = sm.gameObject;
			}
		}
		return nearest;
	}

	// -------------------------------------------------------
	// Percepção – detecção de paredes
	// -------------------------------------------------------

	bool IsNearWall()
	{
		if (!boundsReady) return false;
		Vector3 pos = owner.transform.position;
		return pos.x < worldBounds.min.x + wallMargin ||
			   pos.x > worldBounds.max.x - wallMargin ||
			   pos.y < worldBounds.min.y + wallMargin ||
			   pos.y > worldBounds.max.y - wallMargin;
	}

	// -------------------------------------------------------
	// Wander – geração de pontos aleatórios
	// -------------------------------------------------------

	void PickNewWanderPoint()
	{
		Vector3 pos = owner != null ? owner.transform.position : Vector3.zero;

		if (boundsReady)
		{
			// Gera ponto dentro dos limites do mundo com margem de segurança
			randomPoint = new Vector3(
				Mathf.Clamp(
					Random.Range(pos.x - 12f, pos.x + 12f),
					worldBounds.min.x + wallMargin,
					worldBounds.max.x - wallMargin
				),
				Mathf.Clamp(
					Random.Range(pos.y - 12f, pos.y + 12f),
					worldBounds.min.y + wallMargin,
					worldBounds.max.y - wallMargin
				),
				0f
			);
		}
		else
		{
			// Fallback sem bounds
			randomPoint = new Vector3(
				pos.x + Random.Range(-10f, 10f),
				pos.y + Random.Range(-10f, 10f),
				0f
			);
		}

		direction = (randomPoint - pos).normalized;
		direction.z = 0f;
	}

	IEnumerator WanderRoutine()
	{
		while (true)
		{
			yield return new WaitForSeconds(wanderChangeInterval);
			if (currentState == BotState.Wander)
				PickNewWanderPoint();
		}
	}
}
