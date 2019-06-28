-- insertar traslado
INSERT INTO traslado (comuna_origen, comuna_destino, fecha_viaje, espacio, tipo_mascota_id, descripcion, nombre_contacto, email_contacto, celular_contacto) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);

-- obtener primeros 5 traslado
SELECT id, comuna_origen, comuna_destino, fecha_viaje, espacio, tipo_mascota_id, descripcion, nombre_contacto, email_contacto, celular_contacto FROM traslado ORDER BY id DESC LIMIT 5
-- obtener los siguientes 5
SELECT id, comuna_origen, comuna_destino, fecha_viaje, espacio, tipo_mascota_id, descripcion, nombre_contacto, email_contacto, celular_contacto FROM traslado ORDER BY id DESC LIMIT 5, 5

-- obtener información de un traslado
SELECT id, comuna_origen, comuna_destino, fecha_viaje, espacio, tipo_mascota_id, descripcion, nombre_contacto, email_contacto, celular_contacto FROM traslado WHERE id=?

-- insertar voluntario
INSERT INTO voluntario (nombre_voluntario, email_voluntario, celular_voluntario, espacio_disponible, comuna_disponible, descripcion) VALUES (?, ?, ?, ?, ?, ?);

-- obtener primeros 5 voluntarios
SELECT id, nombre_voluntario, email_voluntario, celular_voluntario, espacio_disponible, comuna_disponible, descripcion FROM voluntario ORDER BY id DESC LIMIT 5
-- obtener los siguientes 5
SELECT id, nombre_voluntario, email_voluntario, celular_voluntario, espacio_disponible, comuna_disponible, descripcion FROM voluntario ORDER BY id DESC LIMIT 5, 5

-- obtener información de un voluntario en particular
SELECT id, nombre_voluntario, email_voluntario, celular_voluntario, espacio_disponible, comuna_disponible, descripcion FROM voluntario WHERE id=?

