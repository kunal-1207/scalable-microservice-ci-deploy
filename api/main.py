from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import uvicorn

app = FastAPI(title="E-commerce API", version="1.0.0")

# Data models
class Product(BaseModel):
    id: int
    name: str
    price: float
    description: Optional[str] = None
    category: str
    stock: int

class Order(BaseModel):
    id: int
    user_id: int
    products: List[dict]  # {product_id: int, quantity: int}
    total_amount: float
    status: str

class User(BaseModel):
    id: int
    email: str
    name: str

# In-memory storage (in production, use database)
products = [
    Product(id=1, name="Laptop", price=999.99, description="High-performance laptop", category="Electronics", stock=50),
    Product(id=2, name="Mouse", price=29.99, description="Wireless mouse", category="Electronics", stock=100),
    Product(id=3, name="Book", price=19.99, description="Programming book", category="Books", stock=75)
]

orders = []
users = [
    User(id=1, email="user@example.com", name="John Doe")
]

# API endpoints
@app.get("/")
async def root():
    return {"message": "E-commerce API", "version": "1.0.0"}

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/products", response_model=List[Product])
async def get_products():
    return products

@app.get("/products/{product_id}", response_model=Product)
async def get_product(product_id: int):
    product = next((p for p in products if p.id == product_id), None)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@app.post("/products", response_model=Product)
async def create_product(product: Product):
    # Check if product ID already exists
    if any(p.id == product.id for p in products):
        raise HTTPException(status_code=400, detail="Product ID already exists")
    products.append(product)
    return product

@app.get("/orders", response_model=List[Order])
async def get_orders():
    return orders

@app.post("/orders", response_model=Order)
async def create_order(order: Order):
    orders.append(order)
    return order

@app.get("/users", response_model=List[User])
async def get_users():
    return users

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)