from functools import partial
from typing import Any

from sqlalchemy import select
from sqlalchemy.orm import Session

from models import Base, Tag, User
from schemas import Role
from utils.authentication import hash_password


def get_or_create_if_not_exists(
    db: Session,
    model: type[Base],
    defaults: dict[str, Any] = {},
    filters: dict[str, Any] = {},
) -> Base | None:
    """
    This function adds a value to the database if it does not already exist.
    It returns the existing value if it already exists, otherwise it returns the newly created value.

    :param db: The database session to use for the operation.
    :type db: Session
    :param model: The SQLAlchemy model class representing the table to operate on.
    :type model: type[Base]
    :param defaults: A dictionary of default values to use when creating a new instance if one does not already exist. The keys should correspond to column names in the model.
    :type defaults: dict[str, Any]
    :param filters: A dictionary of filter conditions to check for existing instances. The keys should correspond to column names in the model, and the values should be the values to filter by.
    :type filters: dict[str, Any]
    :return: The existing instance if it already exists, or the newly created instance if it does not.
    :rtype: Base | None
    """
    instance = db.scalar(select(model).filter_by(**filters))
    if instance:
        return instance

    new_instance = model(**filters, **defaults)
    db.add(new_instance)
    try:
        db.commit()
        return new_instance
    except:
        db.rollback()
        return instance


def seed_standard_values(db: Session) -> None:
    """
    This function seeds the database with standard values if they do not already exist.
    It is called during the initialization of the database.
    """
    create = partial(get_or_create_if_not_exists, db)

    # Create default admin
    create(
        User,
        {
            "name": "Admin",
            "password_hash": hash_password("admin"),
            "email": "admin@cookbookapp.de",
            "role": Role.admin,
        },
        filters={"id": 1},
    )
    # ... and test user
    create(
        User,
        {
            "name": "Test",
            "password_hash": hash_password("test"),
            "email": "test@test.com",
            "role": Role.user,
        },
        filters={"id": 2},
    )

    # Create default tags
    create(Tag, filters={"name": "Frühstück"})
    create(Tag, filters={"name": "Mittagessen"})
    create(Tag, filters={"name": "Abendessen"})
