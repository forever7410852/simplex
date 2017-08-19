
Player = {};
Player.__index = Player;
local this = Player;
local playerArrow;
PlayersParent = UnityEngine.GameObject.Find("Players").transform;


--创建玩家--
function Player:New(playerName,playerId,playerSize,playerColor)
  local temp = {}
  setmetatable(temp,Player)
  temp.name = playerName;
  temp.playerId = playerId;
  temp.playerSize = playerSize;
  temp.playerColor = playerColor;
  temp.moveDirect = Vector2(Mathf.Random(0,1),Mathf.Random(0,1));
  temp.moveSpeed = 1;
  temp.stepTimer = nil;

  temp.obj = UnityEngine.Object.Instantiate(UnityEngine.Resources.Load("Prefabs/Player"));
  temp.obj.name = playerName;
  temp.obj.transform:SetParent(PlayersParent);
  temp.SelfBall = temp.obj.Find("Ball");
  temp.SelfBall.name = playerName.."ball";
  temp.playerArrow = temp.obj.Find("BallArrow");
  --GameObject.SetActive(temp.playerArrow,false)
  temp.playerArrow:SetActive(false);
  temp.obj.transform.position = this.RandomBorn();
  temp.alive = true;

  return temp;
end

function Player.RandomBorn()
  return Vector3(Mathf.Random(0,MaxPos.x), Mathf.Random(0,MaxPos.y),0);
end

function Player:SetSize(newSize)
  self.playerSize = newSize;
  self.round = newSize + 1;
  self.PlayerId = newSize + 1;
end

function Player:Move()
  if(Mathf.Random(0,1000) > 996) then
    PlayerManager.ChangeDirect(self);
  end
  
  local targetPos = Vector2(self.obj.transform.position.x,self.obj.transform.position.y) + Vector2(self.moveSpeed * self.moveDirect.x,self.moveSpeed * self.moveDirect.y);
  self.obj.transform.position = Vector3(Mathf.Clamp(targetPos.x, 0, MaxPos.x), Mathf.Clamp(targetPos.y, 0, MaxPos.y), 0);

  PlayerManager.EatStar(self);
end

function Player:SelfMove(moveDirect,MoveSpeed)
  local round = Mathf.Sqrt(Mathf.Pow(moveDirect.x, 2) + Mathf.Pow(moveDirect.y, 2));
  --print("moveDirect.z = "..moveDirect.z..",moveDirect = "..moveDirect..",round = "..round);
  local targetPos = Vector2(self.obj.transform.position.x,self.obj.transform.position.y) + (MoveSpeed / round) * moveDirect;
  self.obj.transform.position = Vector3(Mathf.Clamp(targetPos.x, 0, MaxPos.x), Mathf.Clamp(targetPos.y, 0, MaxPos.y), 0);
  MainCamera.SetPosition(self.obj.transform.position);

  PlayerManager.EatStar(self);
end

function Player:IsShootByBullet(bullet)
  local dis2Bullet = Mathf.Sqrt(Mathf.Pow(bullet.bullet.transform.position.x - self.obj.transform.position.x, 2) 
    + Mathf.Pow(bullet.bullet.transform.position.y - self.obj.transform.position.y, 2));
  if(dis2Bullet < (bullet.bullet.transform.localScale.x + self.SelfBall.transform.localScale.x)/10)
  then
    local temp = Mathf.Sqrt(Mathf.Max(0, Mathf.Pow(self.SelfBall.transform.lossyScale.x, 2) - Mathf.Pow(bullet.bullet.transform.lossyScale.x * 2, 2)));
    if(temp < 100)
    then
      PlayerManager.DeletePlayer(self);
      print("GameObject.Destroy(player)"..self.playerId);
      --GameObject.Destroy(Player);
    else
      self.SelfBall.transform.localScale = Vector3(temp,temp,1);
    end
    return true;
  else
    return false;
  end
end
--[[
function Player.Awake(obj)
	player = obj;
	--transform = obj.transform;

	logWarn("Awake lua--->>"..gameObject.name);
end

function Player.Start()
  moveSpeed = 1;
  MaxPos = Vector3(1920,1080,0);
  this.PlayerAutoMove();
end

function Player.PlayerAutoMove（）
    TarPos = new Vector3(Random.Range(0, MaxPos.x), Random.Range(0, MaxPos.y), 0);
    moveDirect = TarPos - ball.transform.position;
    round = Mathf.Sqrt(Mathf.Pow(moveDirect.x, 2) + Mathf.Pow(moveDirect.y, 2));
    Invoke("PlayerAutoMove", Random.Range(1, 10));
end

function Player.Update()
  targerPos = player.transform.position + (moveSpeed / round) *moveSpeed;
  player.transform.position = Vector3(Mathf.Clamp(targetPos.x, 0, MaxPos.x), Mathf.Clamp(targetPos.y, 0, MaxPos.y), 0);
  EatBall();
end

--设置玩家位置--
function Player.SetPosition(pos)
    transform.position = pos;
end

--设置玩家大小--
function Player.SetPosition(sca)
    transform.scale = sca;
end

--销毁玩家--
function Player.OnDestroy()
	logWarn("OnDestroy---->>>"..gameObject.name);
end

function Player.IsShootByBullet(bullet)
  dis2Bullet = Mathf.Sqrt(Mathf.Pow(bullet.transform.position.x - player.transform.position.x, 2) + Mathf.Pow(bullet.transform.position.y - player.transform.position.y, 2));
  if(dis2Bullet < (bullet.transform.localScale.x + player.transform.localScale.x)/10)
  then
    local temp = Mathf.Sqrt(Mathf.Max(0, Mathf.Pow(player.transform.lossyScale.x, 2) - Mathf.Pow(bullet.transform.lossyScale.x * 2, 2)));
    if(temp < 100)
    then
      PlayerManager.DeletePlayerById(PlayerId);
      print("GameObject.Destroy(player)"..PlayerId);
      GameObject.Destroy(Player);
    else
      player.transform.localScale = Vector3(temp,temp,1);
    end
    return true;
  else
    return false;
  end
end

function Player.EatBall()
  for i = 0,10 do
    if(IsInBall(pos))
    then
      float a = Mathf.Sqrt(Mathf.Pow(StarManager.Instance.Stars[i].star.transform.lossyScale.x, 2) + Mathf.Pow(ball.transform.lossyScale.x, 2));
      ball.transform.localScale = new Vector3(a, a, 1);
      GameObject.Destroy(StarManager.Instance.Stars[i].star);
      StarManager.Instance.UnitOffset.Add(StarManager.Instance.Stars[i].OffsetX);
      StarManager.Instance.UnitOffset.Add(StarManager.Instance.Stars[i].OffsetY);
      StarManager.Instance.NewStar();
      StarManager.Instance.Stars.Remove(StarManager.Instance.Stars[i]);
    end
  end
end

function Player.IsInBall(pos)
  local dis = Mathf.Sqrt(Mathf.Pow(pos.x - player.transform.position.x, 2) + Mathf.Pow(pos.y - player.transform.position.y, 2));
  return dis < player.transform.localScale.x /10;
end
--]]
function Player:ResetArrow()
  self.playerArrow:SetActive(false);
end

function Player:SetArrow(bulletDirect)
  if(self.playerArrow.activeInHierarchy == false) then
    --print("Player:SetArrow ________");
    self.playerArrow:SetActive(true);
  end
  
  self.playerArrow.transform.localPosition = (self.SelfBall.transform.localScale.x /10/ bulletDirect.magnitude) * bulletDirect; --+ self.SelfBall.transform.position;
  self.playerArrow.transform.localScale = (self.SelfBall.transform.localScale - Vector3(100, 100, 0))/5 + Vector3(100, 100, 0);
end

return this;

