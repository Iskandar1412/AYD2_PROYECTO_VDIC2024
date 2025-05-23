# Usa la imagen oficial de Node.js como base
FROM node:22.9.0

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia el archivo package.json y package-lock.json al contenedor
COPY package*.json ./

# Instala las dependencias de Node.js
RUN npm install

# Copia el resto del código de la aplicación al contenedor
COPY . .

# Expone el puerto que la aplicación va a usar
EXPOSE 3000

# Define el comando para ejecutar la aplicación
CMD ["npm", "start"]