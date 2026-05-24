import { ApiProperty } from '@nestjs/swagger';

import { Regla } from '../entities/regla.entity';
import { Estacion } from '../entities/estacion.enum';
import { FaseAgronomica } from '../entities/fase-agronomica.enum';
import { TipoRecomendacion } from '../entities/tipo-recomendacion.enum';

/**
 * Response DTO para Regla. Incluye nombres calculados via JOIN
 * con catalogos para que el frontend no tenga que hacer lookups extra.
 */
export class ReglaResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty() codigo!: string;
  @ApiProperty() nombre!: string;
  @ApiProperty({ nullable: true }) descripcion!: string | null;
  @ApiProperty({ enum: TipoRecomendacion }) tipoRecomendacion!: TipoRecomendacion;

  // FKs + nombres
  @ApiProperty({ nullable: true }) cultivoId!: string | null;
  @ApiProperty({ nullable: true }) cultivoNombre!: string | null;
  @ApiProperty({ nullable: true }) plagaId!: string | null;
  @ApiProperty({ nullable: true }) plagaNombre!: string | null;
  @ApiProperty({ nullable: true }) tipoSueloId!: string | null;
  @ApiProperty({ nullable: true }) tipoSueloNombre!: string | null;
  @ApiProperty({ nullable: true }) fertilizanteSugeridoId!: string | null;
  @ApiProperty({ nullable: true }) fertilizanteSugeridoNombre!: string | null;

  // Condiciones IF
  @ApiProperty({ nullable: true, enum: FaseAgronomica })
  faseAgronomica!: FaseAgronomica | null;
  @ApiProperty({ nullable: true }) severidadMinima!: string | null;
  @ApiProperty({ nullable: true, enum: Estacion }) estacion!: Estacion | null;
  @ApiProperty({ nullable: true }) diasSinRiegoMinimo!: number | null;
  @ApiProperty({ nullable: true }) diasDesdeSiembraMinimo!: number | null;
  @ApiProperty({ nullable: true }) diasDesdeSiembraMaximo!: number | null;
  @ApiProperty({ nullable: true }) humedadMaxima!: number | null;
  @ApiProperty({ nullable: true }) humedadMinima!: number | null;

  // Accion THEN
  @ApiProperty() accionSugerida!: string;
  @ApiProperty({ nullable: true }) productoSugerido!: string | null;
  @ApiProperty({ nullable: true }) dosisRecomendada!: number | null;
  @ApiProperty({ nullable: true }) unidadRecomendada!: string | null;
  @ApiProperty({ nullable: true }) metodoAplicacion!: string | null;
  @ApiProperty({ nullable: true }) frecuenciaDias!: number | null;

  // Metadatos
  @ApiProperty() prioridad!: number;
  @ApiProperty() fuenteCientifica!: string;
  @ApiProperty() activa!: boolean;
  @ApiProperty({ nullable: true }) notas!: string | null;
  @ApiProperty() createdAt!: Date;
  @ApiProperty() updatedAt!: Date;

  static fromEntity(r: Regla): ReglaResponseDto {
    const dto = new ReglaResponseDto();
    dto.id = r.id;
    dto.codigo = r.codigo;
    dto.nombre = r.nombre;
    dto.descripcion = r.descripcion;
    dto.tipoRecomendacion = r.tipoRecomendacion;

    dto.cultivoId = r.cultivoId;
    dto.cultivoNombre = r.cultivo?.nombre ?? null;
    dto.plagaId = r.plagaId;
    dto.plagaNombre = r.plaga?.nombre ?? null;
    dto.tipoSueloId = r.tipoSueloId;
    dto.tipoSueloNombre = r.tipoSuelo?.nombre ?? null;
    dto.fertilizanteSugeridoId = r.fertilizanteSugeridoId;
    dto.fertilizanteSugeridoNombre = r.fertilizanteSugerido?.nombre ?? null;

    dto.faseAgronomica = r.faseAgronomica;
    dto.severidadMinima = r.severidadMinima;
    dto.estacion = r.estacion;
    dto.diasSinRiegoMinimo = r.diasSinRiegoMinimo;
    dto.diasDesdeSiembraMinimo = r.diasDesdeSiembraMinimo;
    dto.diasDesdeSiembraMaximo = r.diasDesdeSiembraMaximo;
    dto.humedadMaxima = r.humedadMaxima !== null ? Number(r.humedadMaxima) : null;
    dto.humedadMinima = r.humedadMinima !== null ? Number(r.humedadMinima) : null;

    dto.accionSugerida = r.accionSugerida;
    dto.productoSugerido = r.productoSugerido;
    dto.dosisRecomendada = r.dosisRecomendada !== null ? Number(r.dosisRecomendada) : null;
    dto.unidadRecomendada = r.unidadRecomendada;
    dto.metodoAplicacion = r.metodoAplicacion;
    dto.frecuenciaDias = r.frecuenciaDias;

    dto.prioridad = r.prioridad;
    dto.fuenteCientifica = r.fuenteCientifica;
    dto.activa = r.activa;
    dto.notas = r.notas;
    dto.createdAt = r.createdAt;
    dto.updatedAt = r.updatedAt;

    return dto;
  }
}
