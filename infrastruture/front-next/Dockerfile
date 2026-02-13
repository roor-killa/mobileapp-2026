FROM node:20-alpine

WORKDIR /app

# On copie d'abord les fichiers de dépendances pour optimiser le cache
COPY package.json package-lock.json* ./

# On installe les dépendances
RUN npm install

# On copie le reste du code
COPY . .

# Port exposé
EXPOSE 3000

# Commande de démarrage
CMD ["npm", "run", "dev"]
