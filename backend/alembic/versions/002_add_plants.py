"""Add plants tables

Revision ID: 002_add_plants
Revises: 001_init
Create Date: 2026-05-30
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = '002_add_plants'
down_revision = '001_init'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        'plant_catalog',
        sa.Column('id', postgresql.UUID(as_uuid=True),
                  server_default=sa.text('gen_random_uuid()'),
                  nullable=False),
        sa.Column('name', sa.String(200), nullable=False),
        sa.Column('name_latin', sa.String(200), nullable=True),
        sa.Column('plant_type', sa.String(50), nullable=False,
                  server_default='vegetable'),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('days_to_harvest', sa.Integer(), nullable=True),
        sa.Column('sowing_months', postgresql.ARRAY(sa.Integer()),
                  nullable=True),
        sa.Column('harvest_months', postgresql.ARRAY(sa.Integer()),
                  nullable=True),
        sa.Column('is_custom', sa.Boolean(), nullable=False,
                  server_default='false'),
        sa.Column('created_by', postgresql.UUID(as_uuid=True),
                  nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True),
                  server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['created_by'], ['users.id'],
                                ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index('ix_plant_catalog_plant_type',
                    'plant_catalog', ['plant_type'])
    op.create_index('ix_plant_catalog_is_custom',
                    'plant_catalog', ['is_custom'])

    op.create_table(
        'plant_varieties',
        sa.Column('id', postgresql.UUID(as_uuid=True),
                  server_default=sa.text('gen_random_uuid()'),
                  nullable=False),
        sa.Column('plant_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name', sa.String(200), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('is_custom', sa.Boolean(), nullable=False,
                  server_default='false'),
        sa.Column('created_by', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True),
                  server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['plant_id'], ['plant_catalog.id'],
                                ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['created_by'], ['users.id'],
                                ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index('ix_plant_varieties_plant_id',
                    'plant_varieties', ['plant_id'])

    op.create_table(
        'plant_instances',
        sa.Column('id', postgresql.UUID(as_uuid=True),
                  server_default=sa.text('gen_random_uuid()'),
                  nullable=False),
        sa.Column('zone_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('plant_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('variety_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('custom_name', sa.String(200), nullable=True),
        sa.Column('planted_date', sa.Date(), nullable=True),
        sa.Column('quantity', sa.Integer(), nullable=True),
        sa.Column('area_sqm', sa.Numeric(8, 2), nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('status', sa.String(50), nullable=False,
                  server_default='active'),
        sa.Column('created_at', sa.DateTime(timezone=True),
                  server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['zone_id'], ['zones.id'],
                                ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['plant_id'], ['plant_catalog.id'],
                                ondelete='RESTRICT'),
        sa.ForeignKeyConstraint(['variety_id'], ['plant_varieties.id'],
                                ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index('ix_plant_instances_zone_id',
                    'plant_instances', ['zone_id'])
    op.create_index('ix_plant_instances_status',
                    'plant_instances', ['status'])


def downgrade() -> None:
    op.drop_table('plant_instances')
    op.drop_table('plant_varieties')
    op.drop_table('plant_catalog')