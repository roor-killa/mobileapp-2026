.PHONY: help up down restart logs clean psql api

help:
	@echo "🚀 BKN - Commandes Docker"
	@echo "  make up     - Démarrer tous les services"
	@echo "  make down   - Arrêter les services"
	@echo "  make logs   - Voir les logs"
	@echo "  make clean  - Supprimer tout (données incluses)"
	@echo "  make psql   - Se connecter à PostgreSQL"
	@echo "  make api    - Voir logs API"

up:
	docker-compose up -d
	@echo "✅ Services démarrés"
	@echo "📡 API: http://localhost:8000"
	@echo "📊 Adminer: http://localhost:8080"

down:
	docker-compose down
	@echo "✅ Services arrêtés"

logs:
	docker-compose logs -f

clean:
	docker-compose down -v
	@echo "✅ Volumes supprimés"

psql:
	docker exec -it bkn_postgres psql -U bkn_admin -d bkn_db

api:
	docker-compose logs -f api