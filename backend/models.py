from sqlalchemy import Column, Integer, String
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    name = Column(String)
    role = Column(String, default="Citizen")
    phone = Column(String, nullable=True)
    badge = Column(String, nullable=True)
    station = Column(String, nullable=True)
    profile_image = Column(String, nullable=True)
