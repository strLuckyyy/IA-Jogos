using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class GameLogic : MonoBehaviour
{
    [Header("Settings")]
    public int poolSize = 500;
    public float orbLifetime = 30f;
    public float orbSpawnInterval = 2f;
    public int orbsPerSpawn = 5;
    public int nSnakes = 50;

    [Header("Prefabs & References")]
    public GameObject orbPreFab;
    public GameObject snakePrefab;
    public List<AIBehaviour> behaviors = new List<AIBehaviour>();

    [Header("Runtime Data")]
    public List<GameObject> snakes = new List<GameObject>();
    // Esta é a lista que os alunos usarão para a Tomada de Decisão
    public List<GameObject> orbPool = new List<GameObject>();

    private float minX, minY, maxX, maxY;
    private int selectedId;

    void Start()
    {
        SetupBounds();
        InitializeOrbPool();
        SpawnInitialSnakes();

        StartCoroutine(PoolSpawnRoutine());
    }

    void SetupBounds()
    {
        BoxCollider2D col = GetComponent<BoxCollider2D>();
        minX = col.bounds.min.x;
        minY = col.bounds.min.y;
        maxX = col.bounds.max.x;
        maxY = col.bounds.max.y;
    }

    // Criamos todos os orbes no início, desativados
    void InitializeOrbPool()
    {
        GameObject orbParent = new GameObject("OrbPool");
        for (int i = 0; i < poolSize; i++)
        {
            GameObject obj = Instantiate(orbPreFab);
            obj.transform.parent = orbParent.transform;
            obj.SetActive(false);
            orbPool.Add(obj);
        }
    }

    IEnumerator PoolSpawnRoutine()
    {
        while (true)
        {
            for (int i = 0; i < orbsPerSpawn; i++)
            {
                ActivateOrbFromPool();
            }
            yield return new WaitForSeconds(orbSpawnInterval);
        }
    }

    void ActivateOrbFromPool()
    {
        // Busca o primeiro objeto inativo no pool
        GameObject orb = orbPool.FirstOrDefault(o => !o.activeInHierarchy);

        if (orb != null)
        {
            orb.transform.position = new Vector3(Random.Range(minX, maxX), Random.Range(minY, maxY), 0);
            orb.SetActive(true);
            // Inicia o "timer" de desativação centralizado
            StartCoroutine(DeactivateOrbAfterTime(orb, orbLifetime));
        }
    }

    IEnumerator DeactivateOrbAfterTime(GameObject orb, float delay)
    {
        yield return new WaitForSeconds(delay);
        if (orb != null && orb.activeInHierarchy)
        {
            orb.SetActive(false);
        }
    }

    // Método para ser chamado pelo SnakeMovement.cs em vez de Destroy()
    public void CollectOrb(GameObject orb)
    {
        orb.SetActive(false);
    }

    void SpawnInitialSnakes()
    {
        // Lógica original de spawn de cobras mantida e adaptada
        for (int i = 0; i < nSnakes; i++)
        {
            Vector3 pos = new Vector3(Random.Range(minX, maxX), Random.Range(minY, maxY), 0);
            GameObject newSnake = Instantiate(snakePrefab, pos, Quaternion.identity);
            newSnake.name = "SnakeBot_" + i;

            // Atribui comportamento (ex: Dummy)
            newSnake.GetComponentInChildren<SnakeMovement>().SetBehaviour(behaviors[0]);
            snakes.Add(newSnake);
        }

        if (snakes.Count > 0)
        {
            snakes[0].GetComponentInChildren<SnakeMovement>().SetBehaviour(behaviors[1]);
            snakes[0].GetComponentInChildren<SnakeMovement>().selected = true;
        }
    }

    void Update()
    {
        CheckInput();
    }

    void CheckInput()
    {
        if (Input.GetKeyDown(KeyCode.E)) SelectSnake(1);
        if (Input.GetKeyDown(KeyCode.Q)) SelectSnake(-1);
    }

    void SelectSnake(int step)
    {
        snakes[selectedId].GetComponentInChildren<SnakeMovement>().selected = false;
        selectedId = (selectedId + step + snakes.Count) % snakes.Count;
        snakes[selectedId].GetComponentInChildren<SnakeMovement>().selected = true;
    }
}