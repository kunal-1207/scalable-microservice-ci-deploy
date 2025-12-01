import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "version" in data

def test_get_products():
    response = client.get("/products")
    assert response.status_code == 200
    products = response.json()
    assert isinstance(products, list)
    assert len(products) >= 3  # We have 3 sample products

def test_get_product():
    response = client.get("/products/1")
    assert response.status_code == 200
    product = response.json()
    assert product["id"] == 1
    assert "name" in product

def test_get_nonexistent_product():
    response = client.get("/products/999")
    assert response.status_code == 404
    assert "not found" in response.json()["detail"].lower()

def test_create_product():
    new_product = {
        "id": 4,
        "name": "Tablet",
        "price": 299.99,
        "description": "Android tablet",
        "category": "Electronics",
        "stock": 25
    }
    response = client.post("/products", json=new_product)
    assert response.status_code == 200
    product = response.json()
    assert product["name"] == "Tablet"

def test_create_duplicate_product():
    duplicate_product = {
        "id": 1,  # This ID already exists
        "name": "Duplicate Laptop",
        "price": 999.99,
        "category": "Electronics",
        "stock": 1
    }
    response = client.post("/products", json=duplicate_product)
    assert response.status_code == 400
    assert "already exists" in response.json()["detail"]

def test_get_orders():
    response = client.get("/orders")
    assert response.status_code == 200
    orders = response.json()
    assert isinstance(orders, list)

def test_create_order():
    new_order = {
        "id": 1,
        "user_id": 1,
        "products": [
            {"product_id": 1, "quantity": 2}
        ],
        "total_amount": 1999.98,
        "status": "pending"
    }
    response = client.post("/orders", json=new_order)
    assert response.status_code == 200
    order = response.json()
    assert order["status"] == "pending"

def test_get_users():
    response = client.get("/users")
    assert response.status_code == 200
    users = response.json()
    assert isinstance(users, list)
    assert len(users) >= 1