## prueba para desarrollador de software en Frogmi.

### Para ejecutar es repositorio debe usar podman o docker.

#### Instrucciones para iniciar con podman:
iniciar aplicación:
```bash
$ sudo su (super usuario)
# podman-compose up
```
para terminar:

```bash
# podman-compose down
```
si usa docker solo debe eliminar el guión, 'docker compose (up o down)'.

#### Interactuar con la aplicación:

1. directamente en el cliente, en la url: http://localhost/8080
2. accediendo directamente a los endpoint de la api: 
    1. http://localhost:3000/api/features?page=1&per_page
    2. http://localhost:3000/api/features?page=1&per_page&mag_type=ml%2Cmd
    3. obs: mag_type se pueden ingresar multiples opciones de dos maneras:
        1. mag_type[]=ml&mag_type=md....
        2. mag_type=ml%2Cmd...
    4. http://localhost:3000/api/features/{id_feature}/comments

Todos estos endpoint tienen las funcionalidades solicitadas en el enunciado de la prueba.

